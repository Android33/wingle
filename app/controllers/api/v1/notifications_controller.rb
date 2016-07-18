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

    last_like = liked_user.notifications.where(:notification_type => C::Notifications::TYPE[:like]).last
    if last_like.present? && (((Time.now - last_like.created_at) / 1.minute).round) < 120
      return render json: {STATUS_CODE: IM_USED_STATUS_CODE, MSG: C::FAILURE_STATUS_MSG}
    end

    notification = Notification.new
    # receiver.notifications.new
    # you can call user.notifications.all for receiver notifications
    notification.receiver_id = liked_user.id
    notification.sender_id = user.id
    notification.notification_type = C::Notifications::TYPE[:like]
    notification.save

    # faved_user.gcm_token = "dy_E1yCB8kI:APA91bHzfMcBnNKBYGLPyW0D8soHkXGtQrLVLELbD92TsoJLw6JHgVGpQxqGnouUEx9BJk78LqYUBgh0RYQps7cP7mBL4sJ7weLUb9ObmT6Xb1dgq8kVQvDq-tn1bzCVScrL5JfingbU"
    if liked_user.gcm_token
      @unseen_notifications_count = 0
      @all_notifications_count = 0
      @unseen_msgs_total = 0
      get_notifications_msgs_count(liked_user)
      data = {
          :gcm_type => C::Notifications::TYPE[:like],
          :unseen_notifications_count => @unseen_notifications_count,
          :all_notifications_count => @all_notifications_count,
          :unseen_msgs_total => @unseen_msgs_total,
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

  def set_seen
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])
    notification = Notification.find(params[:notification_id])
    notification.seen = true
    notification.save

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, notification: notification}
  end

  def all
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    notifications = user.notifications.all.order(created_at: :desc)
    users_array = []
    if user.blockeds.pluck(:blocked_user_id).present?
      notifications = notifications.where.not(sender_id: user.blockeds.pluck(:blocked_user_id))
    end
    notifications.update_all(seen: true)

    notifications && notifications.each do |notification|
      sender_user = User.find(notification.sender_id)
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
      user_object["notification_type"] =  notification.notification_type
      user_object["notification_create_time"] =  notification.created_at
      user_object["notification_before_mins"] = ((Time.now - notification.created_at) / 1.minute).round
      user_object["notification_id"] = notification.id
      user_object["seen"] =  notification.seen

      users_array << user_object
    end

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end

  def get_notification_chat_count
    user = User.find_by_email(params[:user_email])
    if !user || params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])
    @unseen_notifications_count = 0
    @all_notifications_count = 0
    @unseen_msgs_total = 0
    get_notifications_msgs_count(user)

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, unseen_notifications_count: @unseen_notifications_count,
      unseen_msgs_total: @unseen_msgs_total, all_notifications_count: @all_notifications_count}
  end
end
