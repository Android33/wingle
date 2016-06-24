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
      current_profile_image = Image.find(user.image_id)
      image_order = image.order
      image.order = current_profile_image.order
      current_profile_image.order = image_order
      current_profile_image.save
      image.save
      user.image_id = image.id
      user.image_no = image.user_img_count
      user.save
    end

    if params[:image_text]
      image = Image.new
      image.img = parse_image_data(params[:image_text])
      image.user_id = user.id
      image.user_img_count = (user.imagecount + 1) | 1
      image.save!
      user.image_id = image.id
      user.image_no = image.user_img_count
      user.imagecount = (user.imagecount + 1) | 1
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

    if user.fsetting
      fsetting = user.fsetting
    else
      fsetting = Fsetting.new
      fsetting.user_id = user.id
      fsetting.save
    end

    if params[:interested_in]
      user_info.interested_in = params[:interested_in]
      if params[:interested_in] == "male" || params[:interested_in] == "Male"
        fsetting.show_me_of_gender_with_interest = C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL_MEN]
      elsif params[:interested_in] == "female" || params[:interested_in] == "Female"
        fsetting.show_me_of_gender_with_interest = C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL_WOMEN]
      else
        fsetting.show_me_of_gender_with_interest = C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL]
      end
      fsetting.save
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

    if params[:headline]
      user_info.headline = params[:headline]
    end

    images = user.images.where.not(:user_img_count => user.image_no).order(order: :asc)

    user_info.save
    render json: {STATUS_CODE: OK_STATUS_CODE, user: user, user_info: user_info, images: images}
  end

  def create_profile
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

    if params[:image_text]
      image = Image.new
      image.img = parse_image_data(params[:image_text])
      image.user_id = user.id
      image.user_img_count = (user.imagecount + 1) | 1
      image.save!
      user.image_id = image.id
      user.image_no = image.user_img_count
      user.imagecount = (user.imagecount + 1) | 1
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

    if user.fsetting
      fsetting = user.fsetting
    else
      fsetting = Fsetting.new
      fsetting.user_id = user.id
      fsetting.save
    end

    if params[:interested_in]
      user_info.interested_in = params[:interested_in]
      if params[:interested_in] == "male" || params[:interested_in] == "Male"
        fsetting.show_me_of_gender_with_interest = C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL_MEN]
      elsif params[:interested_in] == "female" || params[:interested_in] == "Female"
        fsetting.show_me_of_gender_with_interest = C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL_WOMEN]
      else
        fsetting.show_me_of_gender_with_interest = C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL]
      end
      fsetting.save
    end
    user_info.save

    # GCM starts here
    gcms_to_notify = User.where("gcm_token is NOT NULL and gcm_token != ''").includes(:nsetting).where(nsettings: { member_alert: true}).pluck(:gcm_token)
    if gcms_to_notify
      data = {
          :gcm_type => C::Notifications::TYPE[:memberalert],
          :user_name => user.name,
          :notification_type => C::Notifications::TYPE[:memberalert],
          :user_id => user.id
      }
      reg_tokens = gcms_to_notify.uniq
      post_args = {
          # :to field can also be used if there is only 1 reg token to send
          :registration_ids => reg_tokens,
          :data => data
      }

      begin
        response = RestClient.post 'http://gcm-http.googleapis.com/gcm/send', post_args.to_json,
                                   :Authorization => 'key=' + C::AUTHORIZE_KEY, :content_type => :json, :accept => :json
      rescue Exception => e
        puts "=========Exception starts==========="
        puts e.message.inspect
        puts "---json Exception ends-----"
      end
    end
    # GCM ends here

    images = user.images.where.not(:user_img_count => user.image_no).order(order: :asc)
    render json: {STATUS_CODE: OK_STATUS_CODE, user: user, user_info: user_info, images: images}
  end

  def upload_text_image
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    if params[:image_text]
      image = Image.new
      image.img = parse_image_data(params[:image_text])
      image.user_id = user.id
      image.user_img_count = (user.imagecount + 1) | 1
      image.order = (user.imagecount + 1) | 1
      image.save!
      user.imagecount = (user.imagecount + 1) | 1
      puts "user.image_id: #{user.image_id}"
      if user.image_id.blank?
        user.image_id = image.id
        user.image_no = image.user_img_count
      end
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

    images = user.images.where.not(:user_img_count => user.image_no).order(order: :asc)

    user_info.save
    render json: {STATUS_CODE: OK_STATUS_CODE, user: user, user_info: user_info, images: images, image_no: user.image_no}
  end

  def update_wingle_id
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    wingle_ids = Userinfo.pluck(:wingle_id)
    puts "wingle_ids #{wingle_ids.inspect}"
    wingle_ids && wingle_ids.each do |wingle_id|
      if wingle_id == params[:wingle_id]
        return render json: {STATUS_CODE: C::CONFLICT_STATUS_CODE, STATUS_MSG: C::WINGLE_ID_NOT_AVAILABLE}
      end
    end
    if user.userinfo
      user_info = user.userinfo
    else
      user_info = Userinfo.new
      user_info.user_id = user.id
    end
    user_info.wingle_id = params[:wingle_id]

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
