class Api::V1::ChatsController < ApplicationController
  respond_to :json
  include UsersHelper

  def create
    require 'rest-client'
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    receiver_id = params[:receiver_id]
    if params[:chat_msg].present?
      chat_msg = params[:chat_msg]
    else
      chat_msg = "nil"
    end
    receiver = User.find(receiver_id)
    chat = Chat.new
    chat.chat_msg = chat_msg
    chat.sender_id = user.id
    chat.receiver_id = receiver.id
    chat.save

    user.chats << chat
    receiver.chats << chat

    minutes = ((Time.now - receiver.last_sign_in_at) / 1.minute).round
    if minutes < 10
      is_online = true
    else
      is_online = false
    end

    if params[:image_text]
      image = Chatimage.new
      image.img = parse_image_data(params[:image_text])
      image.sender_id = user.id
      image.receiver_id = receiver.id
      image.chat_id = chat.id
      image.save!
      chat.chatimage_id = image.id
      chat.save
      # ensure
      clean_tempfile
    else
      chat.chatimage_id = -1
      chat.save
    end

    # receiver.gcm_token = "c-Vm5OpwHf4:APA91bEFf_B_nAYGV9fIuVY_A6IcswJ7AzKTvq5QkLP_jgeGzaR0xqhFU0AUYN_FY6UBk2pgEZD1a4nemR78Rp0g219SNOpEiWdSHCGN3WZPSyBmKWCVgK4uzhYMJCMLtVD0yMFHW9yw"
    if receiver.gcm_token
      get_notifications_msgs_count(receiver)
      data = {
          :gcm_type => C::Notifications::TYPE[:chat],
          :unseen_notifications_count => @unseen_notifications_count,
          :all_notifications_count => @all_notifications_count,
          :unseen_msgs_total => @unseen_msgs_total,
          :chat_user => user.name,
          :chat_msg => chat_msg,
          :chat_img => chat.chatimage_id,
          :sender_id => chat.sender_id,
          :receiver_id => chat.receiver_id
      }
      reg_tokens = [receiver.gcm_token]
      post_args = {
          # :to field can also be used if there is only 1 reg token to send
          :registration_ids => reg_tokens,
          :data => data
      }

      begin
        response = RestClient.post 'http://gcm-http.googleapis.com/gcm/send', post_args.to_json,
                                   :Authorization => 'key=' + C::AUTHORIZE_KEY, :content_type => :json, :accept => :json
        chats = user.chats.where("sender_id = ? OR receiver_id = ?", receiver.id, receiver.id)
        render json: {STATUS_CODE: OK_STATUS_CODE, chat_user_name: receiver.name,
                      chat_user_email: receiver.email, is_online: is_online, chat_user_id: receiver.id, chat_user_image_no: receiver.image_no, chat: chats, MSG: C::SUCCESS_STATUS_MSG}
      rescue Exception => e
        puts "=========Exception starts==========="
        puts e.message.inspect
        puts "---json Exception ends-----"
        return render json: {STATUS_CODE: OK_STATUS_CODE, chat_user_name: receiver.name,
                      chat_user_email: receiver.email, is_online: is_online, chat_user_id: receiver.id, chat_user_image_no: receiver.image_no, chat: chats, MSG: e.message.inspect}
      end
    else
      return render json: {STATUS_CODE: OK_STATUS_CODE, chat_user_name: receiver.name,
                    chat_user_email: receiver.email, is_online: is_online, chat_user_id: receiver.id, chat_user_image_no: receiver.image_no, chat: chats, MSG: C::NO_GCM_FOUND}
    end
  end

  def delete
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    Chat.destroy(params[:chat_msg_id])
    receiver = User.find(params[:receiver_id])
    minutes = ((Time.now - receiver.last_sign_in_at) / 1.minute).round
    if minutes < 10
      is_online = true
    else
      is_online = false
    end

    chats = user.chats.where("sender_id = ? OR receiver_id = ?", receiver.id, receiver.id)


    render json: {STATUS_CODE: OK_STATUS_CODE, chat_user_name: receiver.name,
                      chat_user_email: receiver.email, is_online: is_online, chat_user_id: receiver.id, chat_user_image_no: receiver.image_no, chat: chats, MSG: C::SUCCESS_STATUS_MSG}
  end

  def delete_all
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    puts "params #{params.inspect}"


    chats = user.chats.where("sender_id = ? OR receiver_id = ?", params[:receiver_id], params[:receiver_id])
    chats.destroy_all


    render json: {STATUS_CODE: OK_STATUS_CODE, MSG: C::SUCCESS_STATUS_MSG}
  end

  def delete_all_chats
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    user.chats.destroy_all

    render json: {STATUS_CODE: OK_STATUS_CODE, MSG: C::SUCCESS_STATUS_MSG}
  end

  def by_user_all
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    all_chats = user.chats.all
    sender_ids = all_chats.pluck(:sender_id).uniq
    receiver_ids = all_chats.pluck(:receiver_id).uniq
    #    combine and remove duplicate keys
    chat_user_ids = sender_ids | receiver_ids
    #    remove current user id
    chat_user_ids -= [user.id]
    chats_array = []
    chat_user_ids && chat_user_ids.each do |chat_user_id|

      chats = user.chats.where("sender_id = ? OR receiver_id = ?", chat_user_id.to_i, chat_user_id.to_i)
      chat_user = User.find(chat_user_id)
      chat_object = {}
      chat_object["chat_user_name"] = chat_user.name
      chat_object["chat_user_email"] = chat_user.email
      chat_object["chat_user_id"] = chat_user.id
      chat_object["chat_user_image_id"] = chat_user.image_id
      chat_object["chats"] = chats
#      chats_array["chat_user_email"] = chat_user.email
      chats_array << chat_object
    end
    render json: {STATUS_CODE: OK_STATUS_CODE, all_chats: chats_array}
  end

  def by_user
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    all_chats = user.chats.all.order(created_at: :desc)
    chat_user_ids = user.chats.all.order(created_at: :desc).pluck(:sender_id, :receiver_id)
    chat_user_ids = chat_user_ids.flatten(1).uniq
    #    remove current user id
    chat_user_ids -= [user.id]
    chats_array = []
    unseen_msgs_total = 0
    chat_user_ids && chat_user_ids.each do |chat_user_id|

      last_msg = user.chats.where("sender_id = ? OR receiver_id = ?", chat_user_id.to_i, chat_user_id.to_i).last
      chat_user = User.find(chat_user_id)
      chat_object = {}
      minutes = ((Time.now - chat_user.last_sign_in_at) / 1.minute).round
      if minutes < 10
        chat_object["is_online"] = true
      else
        chat_object["is_online"] = false
      end
      chat_object["chat_user_name"] = chat_user.name
      chat_object["chat_user_email"] = chat_user.email
      chat_object["chat_user_id"] = chat_user.id
      chat_object["chat_user_image_no"] = chat_user.image_no
      chat_object["last_msg"] = last_msg
      chat_object["last_msg_before_mins"] = ((Time.now - last_msg.created_at) / 1.minute).round


      chat_object["unseen_msgs"] = user.chats.where("sender_id = ? AND seen = ?", chat_user_id.to_i, false).count
      unseen_msgs_total += chat_object["unseen_msgs"]

      chats_array << chat_object
    end

    render json: {STATUS_CODE: OK_STATUS_CODE, chats: chats_array, unseen_msgs_total: unseen_msgs_total}
  end

  def by_user_favorites
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    chat_user_ids = user.chats.all.order(created_at: :desc).pluck(:sender_id, :receiver_id)
    chat_user_ids = chat_user_ids.flatten(1).uniq

    fav_user_ids = user.favourites.all.pluck(:fav_user_id)
    #    combine and remove duplicate keys
    chat_user_ids = chat_user_ids & fav_user_ids
    #    remove current user id
    chat_user_ids -= [user.id]
    chats_array = []
    unseen_msgs_total = 0
    chat_user_ids && chat_user_ids.each do |chat_user_id|

      last_msg = user.chats.where("sender_id = ? OR receiver_id = ?", chat_user_id.to_i, chat_user_id.to_i).last
      chat_user = User.find(chat_user_id)
      chat_object = {}
      minutes = ((Time.now - chat_user.last_sign_in_at) / 1.minute).round
      if minutes < 10
        chat_object["is_online"] = true
      else
        chat_object["is_online"] = false
      end
      chat_object["chat_user_name"] = chat_user.name
      chat_object["chat_user_email"] = chat_user.email
      chat_object["chat_user_id"] = chat_user.id
      chat_object["chat_user_image_no"] = chat_user.image_no
      chat_object["last_msg"] = last_msg
      chat_object["last_msg_before_mins"] = ((Time.now - last_msg.created_at) / 1.minute).round

      chat_object["unseen_msgs"] = user.chats.where("sender_id = ? AND seen = ?", chat_user_id.to_i, false).count

      unseen_msgs_total += chat_object["unseen_msgs"]
      chats_array << chat_object
    end

    render json: {STATUS_CODE: OK_STATUS_CODE, chats: chats_array, unseen_msgs_total: unseen_msgs_total}
  end

  def with_user
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    chat_user = User.find(params[:chat_user_id])
    chats = user.chats.where("sender_id = ? OR receiver_id = ?", chat_user.id, chat_user.id)

    minutes = ((Time.now - chat_user.last_sign_in_at) / 1.minute).round

    chats.where("sender_id = ?", chat_user.id).update_all(seen: true)

    if minutes < 10
      is_online = true
    else
      is_online = false
    end

    render json: {STATUS_CODE: OK_STATUS_CODE, chat_user_name: chat_user.name,
                  chat_user_email: chat_user.email, is_online: is_online, chat_user_id: chat_user.id,
                  chat_user_image_no: chat_user.image_no, chat: chats}
  end

  def update_last_seen
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    chat_user = User.find(params[:chat_user_id])
    chats = user.chats.where("sender_id = ? OR receiver_id = ?", chat_user.id, chat_user.id)
    chats.where("sender_id = ?", chat_user.id).update_all(seen: true)

    minutes = ((Time.now - chat_user.last_sign_in_at) / 1.minute).round
    if minutes < 10
      is_online = true
    else
      is_online = false
    end

    get_notifications_msgs_count(user)

    render json: {STATUS_CODE: OK_STATUS_CODE, chat_user_name: chat_user.name,
                  chat_user_email: chat_user.email, is_online: is_online, chat_user_id: chat_user.id,
                  chat_user_image_no: chat_user.image_no, unseen_notifications_count: @unseen_notifications_count,
                  all_notifications_count: @all_notifications_count, unseen_msgs_total: @unseen_msgs_total}
  end

  def parse_image_data(base64_image)
    filename = "upload-image"
    in_content_type, encoding, string = base64_image.split(/[:;,]/)[1..3]

    @tempfile = Tempfile.new(filename)
    @tempfile.binmode
    @tempfile.write Base64.decode64(string)
    @tempfile.rewind

    # for security we want the actual content type, not just what was passed in
    content_type = `file --mime -b #{@tempfile.path}`.split(";")[0]

    # we will also add the extension ourselves based on the above
    # if it's not gif/jpeg/png, it will fail the validation in the upload model
    extension = content_type.match(/gif|jpeg|png/).to_s
    filename += ".#{extension}" if extension

    ActionDispatch::Http::UploadedFile.new({
      tempfile: @tempfile,
      content_type: content_type,
      filename: filename
    })
  end

  def clean_tempfile
    if @tempfile
      @tempfile.close
      @tempfile.unlink
    end
  end
end
