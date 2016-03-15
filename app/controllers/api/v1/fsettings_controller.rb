class Api::V1::FsettingsController < ApplicationController
  respond_to :json


  include UsersHelper

  def update

    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    if user.fsetting
      fsetting = user.fsetting
    else
      fsetting = Fsetting.new
      fsetting.user_id = user.id
    end

    if params[:show_me_of_gender_with_interest]
      fsetting.show_me_of_gender_with_interest = params[:show_me_of_gender_with_interest]
    end

    if params[:show_me_close_to]
      fsetting.show_me_close_to = params[:show_me_close_to]
    end

    if params[:show_me_of_age_min]
      fsetting.show_me_of_age_min = params[:show_me_of_age_min]
    end

    if params[:show_me_of_age_max]
      fsetting.show_me_of_age_max = params[:show_me_of_age_max]
    end

    if params[:show_me_of_city]
      fsetting.show_me_of_city = params[:show_me_of_city]
    end

    if params[:show_me_of_ethnicity]
      fsetting.show_me_of_ethnicity = params[:show_me_of_ethnicity]
    end

    fsetting.save
    render json: {STATUS_CODE: OK_STATUS_CODE, fsetting: fsetting}
  end

  def get

    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    if user.fsetting
      fsetting = user.fsetting
    else
      fsetting = Nsetting.new
      fsetting.user_id = user.id
      fsetting.save
    end

    render json: {STATUS_CODE: C::OK_STATUS_CODE, STATUS_MSG: C::SUCCESS_STATUS_MSG, fsetting: fsetting}
  end
end
