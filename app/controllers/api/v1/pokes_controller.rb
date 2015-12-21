#if you want to authenticate your controller use below line of code
#class Api::V1::UsersController < Api::V1::BaseController
class Api::V1::PokesController < ApplicationController

  include UsersHelper

  def create
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    poke = user.pokes.new
    poke.poked_user_id = params[:poked_user_id]
    poke.save

    return render :json=> {STATUS_CODE: OK_STATUS_CODE, poked_user: poke}
  end
end
