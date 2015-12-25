class Api::V1::RegistrationsController < ApplicationController

  respond_to :json
  include UsersHelper

  def create
    email = params[:user_email]
    password = params[:user_password]
    login_type = params[:login_type]
    name = params[:name]

    newUser = User.new;
    newUser.email = email;
    newUser.name = name;
    newUser.last_sign_in_at = Time.now
    newUser.password = password;
    newUser.login_type = login_type;
    token = newUser.authentication_token;

    if newUser.save
      user = User.find_by_email(email)
      token = user.authentication_token
      update_latlong(user, params[:latitude], params[:longitude])
      render json: {STATUS_CODE: CREATED_STATUS_CODE, user_token: token, user_email: email, name: name}

    else
      render json: {STATUS_CODE: CONFLICT_STATUS_CODE, user_token: "nil", user_email: nil, name: name}
    end

  end
end