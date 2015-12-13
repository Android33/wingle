class Api::V1::UserInfosController < ApplicationController
  respond_to :json

  include UsersHelper
  def create

    user = update_latlong(params[:user_email], params[:latitude], params[:longitude])
    user_info = UserInfo.new

    user_info.gender = params[:gender]
    user_info.birthday = params[:birthday]
    user_info.height = params[:height]
    user_info.ethnicity = params[:ethnicity]
    user_info.body_type = params[:body_type]
    user_info.relation_status = params[:relation_status]
    user_info.interested_in = params[:interested_in]
    user_info.about_me = params[:about_me]
    user_info.wingle_id = params[:wingle_id]
    user_info.city = params[:city]
    user_info.country = params[:country]
    user_info.zipcode = params[:zipcode]
    user_info.user_id = user.id

    user_info.save
    render json: {status: 200}
  end
end
