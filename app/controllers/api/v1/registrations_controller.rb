class Api::V1::RegistrationsController < ApplicationController

  respond_to :json

  def create
    puts "---------------"
    puts params.inspect
    puts "---------------"

    email = params[:user_email]
    password = params[:user_password]

    newUser = User.new;
    newUser.email = email;
    newUser.password = password;
    token = newUser.authentication_token;

    if newUser.save
      user = User.find_by_email(email)
      token = user.authentication_token
      render json: {user_token: token, user_email: email}

    else
      render json: {user_token: "nil", user_email: "Email already exists"}
    end

    # if user.valid_password?(password)
    #   token = user.authentication_token
    # end

    # if token.present?
    #     puts "token"*10
    #   render json: {user_token: token, user_email: email}
    #   # render json: {user_token: token}

    # else
    #     puts "error"*10
    #   render json: false, status: :unprocessable_entity
    # end
  end
end