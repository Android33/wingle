class Api::V1::NsettingsController < ApplicationController
  respond_to :json


  include UsersHelper

  def update

    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    if user.nsetting
      nsetting = user.nsetting
    else
      nsetting = Nsetting.new
      nsetting.user_id = user.id
    end

    nsetting.gender = params[:gender]


    nsetting.save
    render json: {STATUS_CODE: OK_STATUS_CODE, nsetting: nsetting}
  end

  def get

    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    if user.nsetting
      render json: {STATUS_CODE: OK_STATUS_CODE, nsetting: user.nsetting}
    else
      render json: {STATUS_CODE: NOT_FOUND_STATUS_CODE, nsetting: nil}
    end


  end
end
