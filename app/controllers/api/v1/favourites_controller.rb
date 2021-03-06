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
    fav = user.favourites.where(:fav_user_id => faved_user.id)
    if fav.present?

    else
      fav = user.favourites.new
      fav.fav_user_id = faved_user.id
      fav.save
    end

    notification = faved_user.notifications.where(:notification_type => C::Notifications::TYPE[:favorite],
                    :sender_id => user.id)
    if notification.blank?
      notification = Notification.new
      # receiver.notifications.new
      # you can call user.notifications.all for receiver notifications
      notification.receiver_id = faved_user.id
      notification.sender_id = user.id
      notification.notification_type = C::Notifications::TYPE[:favorite]
      notification.save
    else
      notification = notification.first
      notification.seen = false
      notification.save
    end


    # faved_user.gcm_token = "dy_E1yCB8kI:APA91bHzfMcBnNKBYGLPyW0D8soHkXGtQrLVLELbD92TsoJLw6JHgVGpQxqGnouUEx9BJk78LqYUBgh0RYQps7cP7mBL4sJ7weLUb9ObmT6Xb1dgq8kVQvDq-tn1bzCVScrL5JfingbU"
    if faved_user.gcm_token
      get_notifications_msgs_count(faved_user)
      data = {
          :gcm_type => C::Notifications::TYPE[:favorite],
          :unseen_notifications_count => @unseen_notifications_count,
          :all_notifications_count => @all_notifications_count,
          :unseen_msgs_total => @unseen_msgs_total,
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
        render :json=> {STATUS_CODE: OK_STATUS_CODE, fav_user: fav, MSG: C::SUCCESS_STATUS_MSG}
      rescue Exception => e
        puts "=========Exception starts==========="
        puts e.message.inspect
        puts "---json Exception ends-----"
        return render json: {STATUS_CODE: OK_STATUS_CODE, fav_user: fav, MSG: e.message.inspect}
      end
    else
      return render json: {STATUS_CODE: OK_STATUS_CODE, fav_user: fav, MSG: C::NO_GCM_FOUND}
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

    user_ids = user.favourites.all.pluck(:fav_user_id)
    users_array = []

    user_ids && user_ids.each do |fav_user_id|
      # fav_user = User.find(fav_user_id)
      fav_user = User.where("id = ? AND name ILIKE ?",fav_user_id, "%#{params[:query]}%").first
      if fav_user.blank?
        next
      end
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
      user_object["is_favourite"] =  true

      blocked_ids = user.blockeds.pluck(:blocked_user_id)
      if blocked_ids && (blocked_ids.include? fav_user_id)
        user_object["is_blocked"] = true
      else
        user_object["is_blocked"] = false
      end

      users_array << user_object
    end

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end

  def all
    user = User.find_by_email(params[:user_email])
    if !user || params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    user_ids = user.favourites.all.pluck(:fav_user_id)
    if user.blockeds.pluck(:blocked_user_id).present?
      user_ids = user_ids - user.blockeds.pluck(:blocked_user_id)
    end
    users_array = []

    users = User.where(id: user_ids).order("last_sign_in_at desc")

    users && users.each do |fav_user|
      if fav_user.blank? || !(User.where("id = ? AND name ILIKE ?",fav_user.id, "%#{params[:query]}%").first || (fav_user.userinfo.wingle_id && fav_user.userinfo.wingle_id.include?(params[:query])))
        next
      end
      minutes = ((Time.now - fav_user.last_sign_in_at) / 1.minute).round
      user_object = {}
      if minutes < 10
        user_object["is_online"] = true
      else
        user_object["is_online"] = false
      end
      if user.latitude != 0 && user.longitude != 0 && fav_user.latitude != 0 && fav_user.longitude != 0 && fav_user.nsetting.show_my_location == true
        user_object["distance"] = Geocoder::Calculations.distance_between([user.latitude,user.longitude], [fav_user.latitude,fav_user.longitude]).round(3)
      else
        user_object["distance"] = "Unknown"
      end
      user_object["id"] =  fav_user.id
      user_object["name"] =  fav_user.name
      user_object["surname"] =  fav_user.surname
      user_object["image_no"] =  fav_user.image_no
      user_object["poke_count"] =  "plz implement"
      user_object["is_favourite"] =  true

      blocked_ids = user.blockeds.pluck(:blocked_user_id)
      if blocked_ids && (blocked_ids.include? fav_user.id)
        user_object["is_blocked"] = true
      else
        user_object["is_blocked"] = false
      end
      user_object["user_age"] = ((Time.now - fav_user.userinfo.birthday) / 1.year).round
      user_object["gender"] = fav_user.userinfo.gender

      users_array << user_object
    end

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end

  def favorited_me
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    # user_ids = user.favourites.all.pluck(:fav_user_id)
    users_array = []
    user_ids = Favourite.all.where(:fav_user_id => user.id).pluck(:user_id)

    user_ids && user_ids.each do |fav_user_id|
      fav_user = User.find(fav_user_id)
      minutes = ((Time.now - fav_user.last_sign_in_at) / 1.minute).round
      user_object = {}
      if minutes < 10
        user_object["is_online"] = true
      else
        user_object["is_online"] = false
      end
      user_object["is_blocked"] = false
      user_object["id"] =  fav_user.id
      user_object["name"] =  fav_user.name
      user_object["surname"] =  fav_user.surname
      user_object["image_no"] =  fav_user.image_no
      user_object["poke_count"] =  "plz implement"
      user_object["gender"] =  fav_user.userinfo.gender

      users_array << user_object
    end

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end
end
