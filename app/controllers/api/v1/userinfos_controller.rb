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
      image = Image.new
      image.img = parse_image_data(params[:image_text])
      image.user_id = user.id
      image.user_img_count = user.images.count + 1
      image.save!
      user.image_id = image.id
      user.image_no = image.user_img_count
      user.save
      # ensure
        clean_tempfile
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

    user_info.save
    render json: {STATUS_CODE: OK_STATUS_CODE, user: user, user_info: user_info}
  end

  # def create
  #   image = Image.new
  #   image.img = parse_image_data(params[:img])
  #   image.user_id = 3
  #   image.user_img_count = 1
  #   # image.img = params[:image] # Assign a file like this, or
  #   # @upload = Upload.new(upload_params)
  #   image.save!
  # ensure
  #   clean_tempfile
  # end

  def parse_image_data(base64_image)
    filename = "upload-image"
    in_content_type, encoding, string = base64_image.split(/[:;,]/)[1..3]

    @tempfile = Tempfile.new(filename)
    @tempfile.binmode
    @tempfile.write Base64.decode64(string)
    @tempfile.rewind

    # for security we want the actual content type, not just what was passed in
    content_type = `file --mime -b #{@tempfile.path}`.split(";")[0]

    # we will also add the extension ourselves based on the above
    # if it's not gif/jpeg/png, it will fail the validation in the upload model
    extension = content_type.match(/gif|jpeg|png/).to_s
    filename += ".#{extension}" if extension

    ActionDispatch::Http::UploadedFile.new({
      tempfile: @tempfile,
      content_type: content_type,
      filename: filename
    })
  end

  def clean_tempfile
    if @tempfile
      @tempfile.close
      @tempfile.unlink
    end
  end

end
