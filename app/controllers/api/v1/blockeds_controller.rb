#if you want to authenticate your controller use below line of code
#class Api::V1::UsersController < Api::V1::BaseController
class Api::V1::BlockedsController < ApplicationController

  include UsersHelper

  def create
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    block_user = User.find(params[:blocked_user_id])
    blocked = user.blockeds.where(:blocked_user_id => block_user.id)
    if blocked.present?

    else
      blocked = user.blockeds.new
      blocked.blocked_user_id = block_user.id
      blocked.save
    end

    return render json: {STATUS_CODE: OK_STATUS_CODE, blocked_user: blocked}
  end

  def destroy
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    fav = user.blockeds.where(:blocked_user_id => params[:blocked_user_id])
    fav.destroy_all

    return render :json=> {STATUS_CODE: OK_STATUS_CODE}
  end

  def all
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    user_ids = user.blockeds.all.pluck(:blocked_user_id)
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

      blocked_ids = user.blockeds.pluck(:id)
      if blocked_ids && (blocked_ids.include? fav_user_id)
        user_object["is_blocked"] = true
      else
        user_object["is_blocked"] = false
      end

      users_array << user_object
    end

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end
end
