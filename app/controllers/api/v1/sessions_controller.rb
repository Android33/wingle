class Api::V1::SessionsController < ApplicationController
  respond_to :json
  include UsersHelper

  def create
    email = params[:user_email]
    password = params[:user_password]

    user = User.find_by_email(email)
    token = nil

    if user.valid_password?(password)
      token = user.authentication_token
    end

    if token.present?
      update_latlong(user, params[:latitude], params[:longitude])
      if user.userinfo
        info = user.userinfo
        render json: {STATUS_MSG: "USER_INFO_FOUND", STATUS_CODE: OK_STATUS_CODE, user_token: token, user_email: email, name: user.name, image_id: user.image_id,
                      gender: info.gender, height: info.height, ethnicity: info.ethnicity, body_type: info.body_type, relation_status: info.relation_status,
                      interested_in: info.interested_in, about_me: info.about_me, wingle_id: info.wingle_id, city: info.city, id: user.id,
                      country: info.country, zipcode: info.zipcode, address: info.address, birthday: info.birthday}
      else
        render json: {STATUS_MSG: "NO_USER_INFO", STATUS_CODE: OK_STATUS_CODE, user_token: token, user_email: email, name: user.name, image_id: user.image_id, gender: nil, height: nil,
                      ethnicity: nil, body_type: nil, relation_status: nil, id: user.id,
                      interested_in: nil, about_me: nil, wingle_id: nil, city: nil,
                      country: nil, zipcode: nil, address: nil, birthday: nil}
      end
    else
      render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE, user_token: nil, user_email: nil}
    end
  end

  def destroy
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    user.authentication_token = nil
    user.save

    return render :json => {STATUS_CODE: OK_STATUS_CODE}
  end
end
