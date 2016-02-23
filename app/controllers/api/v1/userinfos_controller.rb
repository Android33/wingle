class Api::V1::UserinfosController < ApplicationController
  respond_to :json


  include UsersHelper

  def create
    require 'RMagick'
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
    if params[:image_id]
      image = Image.find(params[:image_id])
      user.image_id = image.id
      user.image_no = image.user_img_count
      user.save
    end

    if params[:image_text]
      data = params[:image_text]# code like this  data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAABPUAAAI9CAYAAABSTE0XAAAgAElEQVR4Xuy9SXPjytKm6ZwnUbNyHs7Jc7/VV9bW1WXWi9q
      image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])
      new_file=File.new("1.png", 'wb')
      new_file.write(image_data)

      image = Image.new
      image.img = new_file # Assign a file like this, or
      image.user_id = user.id
      image.user_img_count = user.images.count + 1
      image.save!
    end

    if user.userinfo
      user_info = user.userinfo
    else
      user_info = Userinfo.new
      user_info.user_id = user.id
    end

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
