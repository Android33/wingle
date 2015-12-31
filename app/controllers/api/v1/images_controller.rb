class Api::V1::ImagesController < ApplicationController
  include UsersHelper

  def upload_img
    # user = User.find_by_email(params[:user_email])
    # if !user
    #   return render json: {STATUS_CODE: BAD_GATEWAY_STATUS_CODE}
    # end
    # if !user || params[:user_token] != user.authentication_token
    #   return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    # end
    # update_latlong(user, params[:latitude], params[:longitude])
    #
    # if user.userinfo
    #   user_info = user.userinfo
    # else
    #   user_info = Userinfo.new
    #   user_info.user_id = user.id
    # end
    #
    # user_info.gender = params[:gender]
    # user_info.birthday = params[:birthday]
    # user_info.height = params[:height]
    # user_info.ethnicity = params[:ethnicity]
    # user_info.body_type = params[:body_type]
    # user_info.relation_status = params[:relation_status]
    # user_info.interested_in = params[:interested_in]
    # user_info.about_me = params[:about_me]
    #
    # user_info.city = params[:city]
    # user_info.country = params[:country]
    # user_info.zipcode = params[:zipcode]
    #
    # user_info.save


    image = Image.new
    image.img = params[:image] # Assign a file like this, or
    image.user_id = params[:user_id]
    image.user_img_count = params[:user_image_count].to_i + 1
    image.save!


    # https://s3-us-west-2.amazonaws.com/wingleuserprofiles/uploads/bubble_1.png
    return render :json => {STATUS_CODE: 200, image: image}
  end

  def upload_img_url
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

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

    img_url = params[:img_url]
    img_url.sub! 'https', 'http'


    image = Image.new
    # For google change https to http
    # image.remote_img_url = "http://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg"
    image.remote_img_url = params[:img_url]
    # for facebook https://graph.facebook.com/xxx/picture?access_token=yyy&type=normal
    # other parameters include  square, small, normal, or large
    # e.g https://graph.facebook.com/799275336836642/picture?type=large
    image.user_id = user.id

    image.user_img_count = user.images.count
    image.save!
    # https://s3-us-west-2.amazonaws.com/wingleuserprofiles/uploads/bubble_1.png
    render json: {STATUS_CODE: C::OK_STATUS_CODE, user: user, user_info: user_info}
  end

end