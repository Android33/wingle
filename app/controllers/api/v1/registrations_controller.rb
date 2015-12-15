class Api::V1::RegistrationsController < ApplicationController

  respond_to :json

  def create
    email = params[:user_email]
    password = params[:user_password]
    login_type = params[:login_type]

    newUser = User.new;
    newUser.email = email;
    newUser.password = password;
    newUser.login_type = login_type;
    token = newUser.authentication_token;

    if newUser.save
      user = User.find_by_email(email)
      token = user.authentication_token
      render json: {status: 201, user_token: token, user_email: email}

    else
      render json: {status: 409, user_token: "nil", user_email: "Email already exists"}
    end

  end
end