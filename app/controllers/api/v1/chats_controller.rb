class Api::V1::ChatsController < ApplicationController
  respond_to :json
  include UsersHelper

  def create
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    receiver_id = params[:receiver_id]
    chat_msg = params[:chat_msg]
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

    chats = user.chats.where("sender_id = ? OR receiver_id = ?", receiver.id, receiver.id)

    render json: {STATUS_CODE: OK_STATUS_CODE, chat_user_name: receiver.name,
                  chat_user_email: receiver.email, is_online: is_online, chat_user_id: receiver.id, chat_user_image_no: receiver.image_no, chat: chats}
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

      puts "before find chats"
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

    all_chats = user.chats.all
    sender_ids = all_chats.pluck(:sender_id).uniq
    receiver_ids = all_chats.pluck(:receiver_id).uniq
    #    combine and remove duplicate keys
    chat_user_ids = sender_ids | receiver_ids
    #    remove current user id
    chat_user_ids -= [user.id]
    chats_array = []
    chat_user_ids && chat_user_ids.each do |chat_user_id|

      puts "before find chats"
      chats = user.chats.where("sender_id = ? OR receiver_id = ?", chat_user_id.to_i, chat_user_id.to_i).last
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
      chat_object["last_msg"] = chats
#      chats_array["chat_user_email"] = chat_user.email
      chats_array << chat_object
    end

    render json: {STATUS_CODE: OK_STATUS_CODE, chats: chats_array}
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
    if minutes < 10
      is_online = true
    else
      is_online = false
    end


    render json: {STATUS_CODE: OK_STATUS_CODE, chat_user_name: chat_user.name,
                  chat_user_email: chat_user.email, is_online: is_online, chat_user_id: chat_user.id,
                  chat_user_image_no: chat_user.image_no, chat: chats}
  end
end