class Api::V1::SessionsController < ApplicationController
  respond_to :json

  def create
    email = params[:user_email]
    password = params[:user_password]

    user = User.find_by_email(email)
    token = nil

    if user.valid_password?(password)
      token = user.authentication_token
    end

    if token.present?
      render json: {status: 200, user_token: token, user_email: email}
    else
      render json: {status: 401, user_token: nil, user_email: nil}
    end
  end
end
