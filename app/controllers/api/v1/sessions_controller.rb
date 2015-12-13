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
      render json: {user_token: token, user_email: email}
    else
      render json: false, status: :unprocessable_entity
    end
  end
end
