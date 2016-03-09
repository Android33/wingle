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
