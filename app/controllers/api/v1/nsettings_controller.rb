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

    nsetting.favorite_me = params[:favorite_me]
    nsetting.msg_alert = params[:msg_alert]
    nsetting.wingle_alert = params[:wingle_alert]
    nsetting.member_alert = params[:member_alert]

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
      render json: {STATUS_CODE: C::OK_STATUS_CODE, STATUS_MSG: C::SUCCESS_STATUS_MSG, nsetting: user.nsetting}
    else
      render json: {STATUS_CODE: C::NOT_FOUND_STATUS_CODE, STATUS_MSG: C::FAILURE_STATUS_MSG, nsetting: nil}
    end
  end
end
