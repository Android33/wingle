#if you want to authenticate your controller use below line of code
#class Api::V1::UsersController < Api::V1::BaseController
class Api::V1::FavouritesController < ApplicationController

  include UsersHelper

  def create
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])


    faved_user = User.find(params[:fav_user_id])
    fav = user.favourites.new
    fav.fav_user_id = faved_user.id
    fav.save

    notification = Notification.new
    # receiver.notifications.new
    # you can call user.notifications.all for receiver notifications
    notification.receiver_id = faved_user.id
    notification.sender_id = user.id
    notification.notification_type = C::Notifications::TYPE[:favorite]
    notification.save

    if faved_user.gcm_token
      data = {
          :gcm_type => C::Notifications::TYPE[:favorite],
          :user_name => user.name,
          :notification_type => C::Notifications::TYPE[:favorite],
          :user_id => user.id,
          :receiver_id => faved_user.id
      }
      reg_tokens = [faved_user.gcm_token]
      post_args = {
          # :to field can also be used if there is only 1 reg token to send
          :registration_ids => reg_tokens,
          :data => data
      }

      begin
        response = RestClient.post 'http://gcm-http.googleapis.com/gcm/send', post_args.to_json,
                                   :Authorization => 'key=' + C::AUTHORIZE_KEY, :content_type => :json, :accept => :json
        render :json=> {STATUS_CODE: OK_STATUS_CODE, fav_user: fav}
      rescue Exception => e
        puts "=========Exception starts==========="
        puts e.message.inspect
        puts "---json Exception ends-----"
        return render json: {STATUS_CODE: C::INTERNAL_SERVER_ERROR_STATUS_CODE, EXCEPTION_MSG: e.message.inspect}
      end
    else
      return render json: {STATUS_CODE: C::INTERNAL_SERVER_ERROR_STATUS_CODE, EXCEPTION_MSG: "No GCM Token User have to resfresh the chat detail page"}
    end
  end

  def destroy
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    fav = user.favourites.where(:fav_user_id => params[:fav_user_id])
    fav.destroy_all

    return render :json=> {STATUS_CODE: OK_STATUS_CODE}
  end

  def all
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    user_ids = user.favourites.all.pluck(:fav_user_id)
    users_array = []

    user_ids && user_ids.each do |fav_user_id|
      fav_user = User.find(fav_user_id)
      minutes = ((Time.now - fav_user.last_sign_in_at) / 1.minute).round
      user_object = {}
      if minutes < 10
        user_object["is_online"] = true
      else
        user_object["is_online"] = false
      end
      user_object["id"] =  fav_user.id
      user_object["name"] =  fav_user.name
      user_object["surname"] =  fav_user.surname
      user_object["image_no"] =  fav_user.image_no
      user_object["poke_count"] =  "plz implement"

      users_array << user_object
    end

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end
end
