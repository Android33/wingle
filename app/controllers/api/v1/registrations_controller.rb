class Api::V1::RegistrationsController < ApplicationController

  respond_to :json
  include UsersHelper

  def create
    email = params[:user_email]
    password = params[:user_password]

    newUser = User.new;

    newUser.email = email

    newUser.last_sign_in_at = Time.now
    newUser.password = password


    if params[:name].present?
      newUser.name = params[:name]
    else
      newUser.name = ""
    end

    if params[:login_type].present?
      newUser.login_type = params[:login_type]
    end

    token = newUser.authentication_token

    if newUser.save
      nsetting = Nsetting.new
      nsetting.user_id = newUser.id
      nsetting.save

      user = User.find_by_email(email)
      token = user.authentication_token
      update_latlong(user, params[:latitude], params[:longitude])
      render json: {STATUS_MSG: "NO_USER_INFO", id: user.id,  STATUS_CODE: CREATED_STATUS_CODE, user_token: token, user_email: email, name: user.name, nsetting: nsetting}

    else
      render json: {STATUS_MSG: "NO_USER_INFO", STATUS_CODE: CONFLICT_STATUS_CODE, user_token: "nil", user_email: nil, name: ""}
    end

  end
end
