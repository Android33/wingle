class Api::V1::GsettingsController < ApplicationController
  respond_to :json


  include UsersHelper

  def update

    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    if user.gsetting
      gsetting = user.gsetting
    else
      gsetting = Gsetting.new
      gsetting.user_id = user.id
    end

    gsetting.sound = params[:sound]
    gsetting.vibration = params[:vibration]
    gsetting.notification = params[:notification]
    gsetting.led = params[:led]
    gsetting.save

    render json: {STATUS_CODE: OK_STATUS_CODE, gsetting: gsetting}
  end

  def get

    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    if user.gsetting
      render json: {STATUS_CODE: C::OK_STATUS_CODE, STATUS_MSG: C::SUCCESS_STATUS_MSG, nsetting: user.gsetting}
    else
      render json: {STATUS_CODE: C::NOT_FOUND_STATUS_CODE, STATUS_MSG: C::FAILURE_STATUS_MSG, gsetting: nil}
    end
  end
end
