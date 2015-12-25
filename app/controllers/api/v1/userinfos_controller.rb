class Api::V1::UserinfosController < ApplicationController
  respond_to :json


  include UsersHelper

  def create

    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    name = params[:name]
    if (name.present?)
      puts "name #{name}"
      user.name = params[:name]
      user.save
    end
    if user.userinfo
      user_info = user.userinfo
    else
      user_info = Userinfo.new
      user_info.user_id = user.id
    end

    # InviteMailer.invit_email().deliver


    user_info.gender = params[:gender]
    user_info.birthday = params[:birthday]
    user_info.height = params[:height]
    user_info.ethnicity = params[:ethnicity]
    user_info.body_type = params[:body_type]
    user_info.relation_status = params[:relation_status]
    user_info.interested_in = params[:interested_in]
    user_info.about_me = params[:about_me]

    user_info.city = params[:city]
    user_info.country = params[:country]
    user_info.zipcode = params[:zipcode]

    user_info.save
    render json: {STATUS_CODE: OK_STATUS_CODE, user: user, user_info: user_info}
  end
end
