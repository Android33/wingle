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

    fav = user.favourites.new
    fav.fav_user_id = params[:fav_user_id]
    fav.save

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, fav_user: fav}
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
      user_object["user_image_id"] =  fav_user.image_id
      user_object["poke_count"] =  "plz implement"

      users_array << user_object
    end

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end
end
