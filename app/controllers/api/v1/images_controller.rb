class Api::V1::ImagesController < ApplicationController
  include UsersHelper

  def upload_img_with_file

    image = Image.new
    image.img = params[:image] # Assign a file like this, or
    image.user_id = params[:user_id]
    image.user_img_count = params[:user_image_count].to_i + 1
    image.save!

    return render :json => {STATUS_CODE: OK_STATUS_CODE, image: image}
  end

  def upload_image_with_url
    user = User.find_by_email(params[:user_email])
    if !user
      return render json: {STATUS_CODE: CONFLICT_STATUS_CODE}
    end
    begin
      puts "==========params start=========="
      puts params.inspect
      puts "----params end----"

      if !user.present? || !user.authentication_token || params[:user_token] != user.authentication_token
        return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE, user: user}
      end
      update_latlong(user, params[:latitude], params[:longitude])

      if params[:name]
        user.name = params[:name]
        user.save
      end

      if user.userinfo
        user_info = user.userinfo
      else
        user_info = Userinfo.new
        user_info.user_id = user.id
      end

      if params[:gender]
        user_info.gender = params[:gender]
      end
      if params[:birthday]
        user_info.birthday = params[:birthday]
      end
      if params[:height]
        user_info.height = params[:height]
      end

      if params[:ethnicity]
        user_info.ethnicity = params[:ethnicity]
      end
      if params[:body_type]
        user_info.body_type = params[:body_type]
      end
      if params[:relation_status]
        user_info.relation_status = params[:relation_status]
      end
      if params[:interested_in]
        user_info.interested_in = params[:interested_in]
      end
      if params[:about_me]
        user_info.about_me = params[:about_me]
      end

      if params[:city]
        user_info.city = params[:city]
      end

      if params[:country]
        user_info.country = params[:country]
      end
      if params[:zipcode]
        user_info.zipcode = params[:zipcode]
      end

      if params[:wingle_id] && params[:wingle_id] != ""
        wingle_ids = Userinfo.pluck(:wingle_id)
        wingle_ids && wingle_ids.each do |wingle_id|
          if wingle_id == params[:wingle_id]
            return render json: {STATUS_CODE: C::CONFLICT_STATUS_CODE, STATUS_MSG: C::WINGLE_ID_NOT_AVAILABLE}
          end
        end
        user_info.wingle_id = params[:wingle_id]
      end
      user_info.save


      img_url = params[:image_url]
      img_url.sub! 'https', 'http'
      image = Image.new
      # For google change https to http
      # image.remote_img_url = "http://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg"
      image.remote_img_url = img_url
      # https://graph.facebook.com/799275336836642/picture?type=large
      image.user_id = user.id


      image.user_img_count = user.images.count
      image.save!
      user.image_id = image.id
      user.image_no = image.user_img_count
      user.save
    rescue Exception => e
      puts "=========Exception starts==========="
      puts e.message.inspect
      puts "---json Exception ends-----"
      return render json: {STATUS_CODE: C::INTERNAL_SERVER_ERROR_STATUS_CODE, EXCEPTION_MSG: e.message.inspect}
    end
    # https://s3-us-west-2.amazonaws.com/wingleuserprofiles/uploads/bubble_1.png
    return render json: {STATUS_CODE: C::OK_STATUS_CODE, image: image, user_info: user_info, user: user}
  end

end