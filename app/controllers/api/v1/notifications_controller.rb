class Api::V1::NotificationsController < ApplicationController
  include UsersHelper

  # def create
  #   user = User.find_by_email(params[:user_email])
  #   if params[:user_token] != user.authentication_token
  #     return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
  #   end
  #   update_latlong(user, params[:latitude], params[:longitude])
  #
  #
  #   faved_user = User.find(params[:fav_user_id])
  #   notification = Notification.new
  #   # receiver.notifications.new
  #   # you can call user.notifications.all for receiver notifications
  #   notification.receiver_id = faved_user.id
  #   notification.sender_id = user.id
  #   notification.notification_type = C::Notifications::TYPE[:favorite]
  #   notification.save
  # end
  #
  # def destroy
  #   user = User.find_by_email(params[:user_email])
  #   if params[:user_token] != user.authentication_token
  #     return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
  #   end
  #   update_latlong(user, params[:latitude], params[:longitude])
  #
  #   fav = user.favourites.where(:fav_user_id => params[:fav_user_id])
  #   fav.destroy_all
  #
  #   return render :json=> {STATUS_CODE: OK_STATUS_CODE}
  # end

  def like
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    liked_user = User.find(params[:liked_user_id])


    notification = Notification.new
    # receiver.notifications.new
    # you can call user.notifications.all for receiver notifications
    notification.receiver_id = liked_user.id
    notification.sender_id = user.id
    notification.notification_type = C::Notifications::TYPE[:like]
    notification.save

    # faved_user.gcm_token = "dy_E1yCB8kI:APA91bHzfMcBnNKBYGLPyW0D8soHkXGtQrLVLELbD92TsoJLw6JHgVGpQxqGnouUEx9BJk78LqYUBgh0RYQps7cP7mBL4sJ7weLUb9ObmT6Xb1dgq8kVQvDq-tn1bzCVScrL5JfingbU"
    if liked_user.gcm_token
      data = {
          :gcm_type => C::Notifications::TYPE[:like],
          :user_name => user.name,
          :notification_type => C::Notifications::TYPE[:favorite],
          :user_id => user.id,
          :receiver_id => liked_user.id
      }
      reg_tokens = [liked_user.gcm_token]
      post_args = {
          # :to field can also be used if there is only 1 reg token to send
          :registration_ids => reg_tokens,
          :data => data
      }

      begin
        response = RestClient.post 'http://gcm-http.googleapis.com/gcm/send', post_args.to_json,
                                   :Authorization => 'key=' + C::AUTHORIZE_KEY, :content_type => :json, :accept => :json
        render :json=> {STATUS_CODE: OK_STATUS_CODE, MSG: C::SUCCESS_STATUS_MSG}
      rescue Exception => e
        puts "=========Exception starts==========="
        puts e.message.inspect
        puts "---json Exception ends-----"
        return render json: {STATUS_CODE: OK_STATUS_CODE, MSG: e.message.inspect}
      end
    else
      return render json: {STATUS_CODE: OK_STATUS_CODE, MSG: C::NO_GCM_FOUND}
    end
  end

  def all
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    user_ids = user.notifications.all.pluck(:sender_id)
    notification_ids = user.notifications.all.pluck(:id)
    users_array = []

    puts "user_ids #{user_ids}"

    user_ids && user_ids.each_with_index do |user_id, index|
      sender_user = User.find(user_id)
      minutes = ((Time.now - sender_user.last_sign_in_at) / 1.minute).round
      user_object = {}
      if minutes < 10
        user_object["is_online"] = true
      else
        user_object["is_online"] = false
      end
      user_object["id"] =  sender_user.id
      user_object["name"] =  sender_user.name
      user_object["image_no"] =  sender_user.image_no
      noti =  user.notifications.find(notification_ids[index])
      user_object["notification_type"] =  noti.notification_type
      user_object["notification_create_time"] =  noti.created_at

      users_array << user_object
    end

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end
end
