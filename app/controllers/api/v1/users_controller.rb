#if you want to authenticate your controller use below line of code
#class Api::V1::UsersController < Api::V1::BaseController
class Api::V1::UsersController < ApplicationController
  # before_action :authenticate_user!
  respond_to :json

  include UsersHelper
  # include c

  def index
  end

  def getAuthToken
    var token = Devise.friendly_token
  end

  def near_users

    user = User.find_by_email(params[:user_email])
    if !user || params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    latitude = params[:latitude]
    longitude = params[:longitude]
    #    distance = params[:distance]
    #    hardcode distance 50 km
    distance = 50
    if latitude == "0.0" && longitude == "0.0"
      users = User.all.order("id asc").limit(50).joins(:userinfo)
    else
      users = User.near([latitude, longitude], distance, :order => "distance").joins(:userinfo)
    end

    if user.fsetting
      fsetting = user.fsetting
    else
      fsetting = Fsetting.new
      fsetting.user_id = user.id
      fsetting.save
    end

    user_interested_in = C::FSettings::GENDER[:FEMALE]
    user_gender = C::FSettings::GENDER[:MALE]

    if fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_WOMEN_LIKE_MEN]
      user_interested_in = C::FSettings::GENDER[:MALE]
      user_gender = C::FSettings::GENDER[:FEMALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_WOMEN_LIKE_WOMEN]
      user_interested_in = C::FSettings::GENDER[:FEMALE]
      user_gender = C::FSettings::GENDER[:FEMALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL_WOMEN]
      user_interested_in = C::FSettings::GENDER[:UNKNOWN]
      user_gender = C::FSettings::GENDER[:FEMALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_MEN_LIKE_WOMEN]
      user_interested_in = C::FSettings::GENDER[:FEMALE]
      user_gender = C::FSettings::GENDER[:MALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_MEN_LIKE_MEN]
      user_interested_in = C::FSettings::GENDER[:MALE]
      user_gender = C::FSettings::GENDER[:MALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL_MEN]
      user_interested_in = C::FSettings::GENDER[:UNKNOWN]
      user_gender = C::FSettings::GENDER[:MALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL]
      user_interested_in = C::FSettings::GENDER[:UNKNOWN]
      user_gender = C::FSettings::GENDER[:UNKNOWN]
    end

    if user_gender != C::FSettings::GENDER[:UNKNOWN] && user_interested_in != C::FSettings::GENDER[:UNKNOWN]
        users = users.where("userinfos.gender = ? AND userinfos.interested_in = ?", user_gender, user_interested_in)
    elsif user_gender == C::FSettings::GENDER[:UNKNOWN] && user_interested_in != C::FSettings::GENDER[:UNKNOWN]
        users = users.where("userinfos.interested_in = ?", user_interested_in)
    elsif user_gender == C::FSettings::GENDER[:UNKNOWN] && user_interested_in == C::FSettings::GENDER[:UNKNOWN]
      users = User.all.limit(50).joins(:userinfo)

    elsif user_gender != C::FSettings::GENDER[:UNKNOWN] && user_interested_in == C::FSettings::GENDER[:UNKNOWN]
        users = users.where("userinfos.gender = ?", user_gender)
    end

    users_array = []
    users = users.where.not(name: "", is_account_active: false)
    users = users.where.not(:id => user.id)
    if user.blockeds.pluck(:blocked_user_id).present?
      users = users.where(["users.id NOT IN (?)", user.blockeds.pluck(:blocked_user_id)])
    end

    if params[:query].present? && params[:query] != ""
      users = users.where("name ILIKE ? OR userinfos.wingle_id ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    users = users.order("last_sign_in_at desc")

    users && users.each do |near_user|
      minutes = ((Time.now - near_user.last_sign_in_at) / 1.minute).round
      user_object = {}
      if minutes < 10
        user_object["is_online"] = true
      else
        user_object["is_online"] = false
      end
      if user.latitude != 0 && user.longitude != 0 && near_user.latitude != 0 && near_user.longitude != 0 && near_user.nsetting.show_my_location == true
        user_object["distance"] = Geocoder::Calculations.distance_between([user.latitude,user.longitude], [near_user.latitude,near_user.longitude]).round(3)
      else
        user_object["distance"] = "Unknown"
      end
      user_object["id"] = near_user.id
      user_object["name"] = near_user.name
      user_object["surname"] = near_user.surname
      user_object["image_no"] = near_user.image_no

      if user.favourites.where(:fav_user_id => near_user.id).count > 0
        user_object["is_favourite"] = true
      else
        user_object["is_favourite"] = false
      end

      blocked_ids = user.blockeds.pluck(:blocked_user_id)
      if blocked_ids && (blocked_ids.include? near_user.id)
        user_object["is_blocked"] = true
      else
        user_object["is_blocked"] = false
      end
      user_object["user_age"] = ((Time.now - near_user.userinfo.birthday) / 1.year).round
      user_object["gender"] = near_user.userinfo.gender

      users_array << user_object
    end

    return render :json => {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end

  def online_users

    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    latitude = params[:latitude]
    longitude = params[:longitude]
    #    distance = params[:distance]
    #    hardcode distance 50 km
    distance = 100
    users = User.near([latitude, longitude], distance, :order => "distance")
    users = users.where.not(:id => user.id)

    users_array = []

    users && users.each do |near_user|
      minutes = ((Time.now - near_user.last_sign_in_at) / 1.minute).round
      user_object = {}
      if minutes < 10
        user_object["is_online"] = true
      else
        next
      end
      user_object["id"] = near_user.id
      user_object["name"] = near_user.name
      user_object["surname"] = near_user.surname
      user_object["image_id"] = near_user.image_id

      if user.favourites.where(:fav_user_id => near_user.id).count > 0
        user_object["is_favourite"] = true
      else
        user_object["is_favourite"] = false
      end
      users_array << user_object
    end

    return render :json => {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end

  def filter_users

    user = User.find_by_email(params[:user_email])
    if !user || params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    latitude = params[:latitude]
    longitude = params[:longitude]
    distance = params[:distance]
    city = params[:city]
    age = params[:age]

    age_city = 0
    if age && age != 0 && age != "0"
      age_city = 1
    end
    if city && city != ""
      age_city += 2
    end
    # age_city 0 when no age or city
    # age_city 1 when only age
    # age_city 2 when only city
    # age_city 3 when both age and city
    puts "age_city: #{age_city}"

    if !distance || distance == 0 || distance == "0"
      users = User.all
    else
      users = User.near([latitude, longitude], distance, :order => "distance")
    end

    users = users.where.not(:id => user.id)
    users_array = []
    users && users.each do |near_user|
      user_object = {}
      user_object["id"] = near_user.id
      user_object["name"] = near_user.name
      user_object["image_no"] = near_user.image_no
      user_info = users.find(near_user.id).userinfo
      if !user_info
        next
      end
      # Means only age parameter exists not the city
      if age_city == 1 && user_info.birthday
        user_age = ((Time.now - user_info.birthday) / 1.year).round
        puts "age: #{age} user_age: #{user_age}"
        next if age.to_i != user_age

        # Means only city parameter exists not the age
      elsif age_city == 2
        puts "Means only city parameter exists not the age"
        # Equal ignore case syntax city.casecmp(user_info.city).zero? will return true when strings equal
        next if !city.casecmp(user_info.city).zero?

        # Means both parameters exists age and city
      elsif age_city == 3 && user_info.birthday && user_info.city
        user_age = ((Time.now - user_info.birthday) / 1.year).round
        puts "age: #{age.to_i.class} user_age: #{user_age.class}"
        next if age.to_i != user_age

        next if !city.casecmp(user_info.city).zero?
      end

      minutes = ((Time.now - near_user.last_sign_in_at) / 1.minute).round
      if minutes < 10
        user_object["is_online"] = true
      else
        user_object["is_online"] = false
      end

      if user.favourites.where(:fav_user_id => near_user.id).count > 0
        user_object["is_favourite"] = true
      else
        user_object["is_favourite"] = false
      end

      users_array << user_object
    end


    return render :json => {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end

  def my_filter_users

    user = User.find_by_email(params[:user_email])
    if !user || params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    distance = 100
    if user.fsetting
      fsetting = user.fsetting
    else
      fsetting = Fsetting.new
      fsetting.user_id = user.id
      fsetting.save
    end
    # User.joins(:userinfo).where("userinfos.gender = ?", 'Male')
    user_interested_in = C::FSettings::GENDER[:FEMALE]
    user_gender = C::FSettings::GENDER[:MALE]

    if fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_WOMEN_LIKE_MEN]
      user_interested_in = C::FSettings::GENDER[:MALE]
      user_gender = C::FSettings::GENDER[:FEMALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_WOMEN_LIKE_WOMEN]
      user_interested_in = C::FSettings::GENDER[:FEMALE]
      user_gender = C::FSettings::GENDER[:FEMALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL_WOMEN]
      user_interested_in = C::FSettings::GENDER[:UNKNOWN]
      user_gender = C::FSettings::GENDER[:FEMALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_MEN_LIKE_WOMEN]
      user_interested_in = C::FSettings::GENDER[:FEMALE]
      user_gender = C::FSettings::GENDER[:MALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_MEN_LIKE_MEN]
      user_interested_in = C::FSettings::GENDER[:MALE]
      user_gender = C::FSettings::GENDER[:MALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL_MEN]
      user_interested_in = C::FSettings::GENDER[:UNKNOWN]
      user_gender = C::FSettings::GENDER[:MALE]

    elsif fsetting.show_me_of_gender_with_interest == C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL]
      user_interested_in = C::FSettings::GENDER[:UNKNOWN]
      user_gender = C::FSettings::GENDER[:UNKNOWN]
    end

    if fsetting.show_me_close_to == C::FSettings::SHOW_ME_CLOSE_TO[:SHOW_ME_CLOSE_TO_HERE]
      distance = 20
    elsif fsetting.show_me_close_to == C::FSettings::SHOW_ME_CLOSE_TO[:SHOW_ME_CLOSE_TO_CITY]
      distance = 50
    elsif fsetting.show_me_close_to == C::FSettings::SHOW_ME_CLOSE_TO[:SHOW_ME_CLOSE_TO_STATE]
      distance = 200
    elsif fsetting.show_me_close_to == C::FSettings::SHOW_ME_CLOSE_TO[:SHOW_ME_CLOSE_TO_COUNTRY]
      distance = 500
    elsif fsetting.show_me_close_to == C::FSettings::SHOW_ME_CLOSE_TO[:SHOW_ME_CLOSE_TO_WORLD]
      distance = 1000
    end


    if user.latitude != 0.0 && user.longitude != 0.0
      users = User.near([user.latitude, user.longitude], distance, :order => "distance").joins(:userinfo)
      if user_gender != C::FSettings::GENDER[:UNKNOWN] && user_interested_in != C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity != C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = users.where("userinfos.gender = ? AND userinfos.interested_in = ? AND userinfos.ethnicity = ?", user_gender, user_interested_in, fsetting.show_me_of_ethnicity)
      elsif user_gender == C::FSettings::GENDER[:UNKNOWN] && user_interested_in != C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity != C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = users.where("userinfos.interested_in = ? AND userinfos.ethnicity = ?", user_interested_in, fsetting.show_me_of_ethnicity)
      elsif user_gender == C::FSettings::GENDER[:UNKNOWN] && user_interested_in == C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity != C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = users.where("userinfos.ethnicity = ?", fsetting.show_me_of_ethnicity)
      elsif user_gender == C::FSettings::GENDER[:UNKNOWN] && user_interested_in == C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity == C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]


      elsif user_gender == C::FSettings::GENDER[:UNKNOWN] && user_interested_in != C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity == C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = users.where("userinfos.interested_in = ?", user_interested_in)
      elsif user_gender != C::FSettings::GENDER[:UNKNOWN] && user_interested_in == C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity != C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = users.where("userinfos.gender = ? AND userinfos.ethnicity = ?", user_gender, fsetting.show_me_of_ethnicity)
      elsif user_gender != C::FSettings::GENDER[:UNKNOWN] && user_interested_in == C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity == C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = users.where("userinfos.gender = ?", user_gender)

      elsif user_gender != C::FSettings::GENDER[:UNKNOWN] && user_interested_in != C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity == C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = users.where("userinfos.gender = ? AND userinfos.interested_in = ?", user_gender, user_interested_in)
      end
    else
      if user_gender != C::FSettings::GENDER[:UNKNOWN] && user_interested_in != C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity != C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = User.all.joins(:userinfo).where("userinfos.gender = ? AND userinfos.interested_in = ? AND userinfos.ethnicity = ?", user_gender, user_interested_in, fsetting.show_me_of_ethnicity)
      elsif user_gender == C::FSettings::GENDER[:UNKNOWN] && user_interested_in != C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity != C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = User.all.joins(:userinfo).where("userinfos.interested_in = ? AND userinfos.ethnicity = ?", user_interested_in, fsetting.show_me_of_ethnicity)
      elsif user_gender == C::FSettings::GENDER[:UNKNOWN] && user_interested_in == C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity != C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = User.all.joins(:userinfo).where("userinfos.ethnicity = ?", fsetting.show_me_of_ethnicity)
      elsif user_gender == C::FSettings::GENDER[:UNKNOWN] && user_interested_in == C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity == C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
        users = User.all.limit(50).joins(:userinfo)

      elsif user_gender == C::FSettings::GENDER[:UNKNOWN] && user_interested_in != C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity == C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = User.all.joins(:userinfo).where("userinfos.interested_in = ?", user_interested_in)
      elsif user_gender != C::FSettings::GENDER[:UNKNOWN] && user_interested_in == C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity != C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = User.all.joins(:userinfo).where("userinfos.gender = ? AND userinfos.ethnicity = ?", user_gender, fsetting.show_me_of_ethnicity)
      elsif user_gender != C::FSettings::GENDER[:UNKNOWN] && user_interested_in == C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity == C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = User.all.joins(:userinfo).where("userinfos.gender = ?", user_gender)

      elsif user_gender != C::FSettings::GENDER[:UNKNOWN] && user_interested_in != C::FSettings::GENDER[:UNKNOWN] && fsetting.show_me_of_ethnicity == C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]
          users = User.all.joins(:userinfo).where("userinfos.gender = ? AND userinfos.interested_in = ?", user_gender, user_interested_in)
      end
    end

    if users
      users = users.where.not(name: "", is_account_active: false)
      if user.blockeds.pluck(:blocked_user_id).present?
        users = users.where(["users.id NOT IN (?)", user.blockeds.pluck(:blocked_user_id)])
      end
      users = users.where.not(:id => user.id)
      if params[:query].present? && params[:query] != ""
        users = users.where("name ILIKE ? OR userinfos.wingle_id ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
      end
    end
    # users = users.where("userinfos.birthday < ? AND userinfos.birthday > ?", (Time.now - fsetting.show_me_of_age_min.to_i.year), (Time.now - (fsetting.show_me_of_age_max).to_i.year))
    users_array = []
    users = users.order("last_sign_in_at desc")
    users && users.each do |near_user|
      user_object = {}
      user_object["id"] = near_user.id
      user_object["name"] = near_user.name
      user_object["image_no"] = near_user.image_no
      user_info = users.find(near_user.id).userinfo
      if !user_info
        next
      end
      if user.latitude != 0 && user.longitude != 0 && near_user.latitude != 0 && near_user.longitude != 0 && near_user.nsetting.show_my_location == true
        user_object["distance"] = Geocoder::Calculations.distance_between([user.latitude,user.longitude], [near_user.latitude,near_user.longitude]).round(3)
      else
        user_object["distance"] = "Unknown"
      end
      user_age = ((Time.now - user_info.birthday) / 1.year).round
      next if (user_age > fsetting.show_me_of_age_max.to_i || user_age < fsetting.show_me_of_age_min.to_i)

      minutes = ((Time.now - near_user.last_sign_in_at) / 1.minute).round
      if minutes < 10
        user_object["is_online"] = true
      else
        user_object["is_online"] = false
      end

      if user.favourites.where(:fav_user_id => near_user.id).count > 0
        user_object["is_favourite"] = true
      else
        user_object["is_favourite"] = false
      end

      blocked_ids = user.blockeds.pluck(:blocked_user_id)
      if blocked_ids && (blocked_ids.include? near_user.id)
        user_object["is_blocked"] = true
      else
        user_object["is_blocked"] = false
      end

      user_object["user_age"] = ((Time.now - user_info.birthday) / 1.year).round
      user_object["gender"] = user_info.gender

      users_array << user_object
    end

    return render :json => {STATUS_CODE: OK_STATUS_CODE, users: users_array}
  end

  def login_signup
    puts params.inspect
    email = params[:user_email]
    password = params[:user_password]

    user = User.find_by_email(email)
    if user && user.nsetting
      user.is_account_active = true
      nsetting = user.nsetting
    end
    token = nil
    if user
      if user.valid_password?(password)
        if params[:login_type].present?
          user.login_type = params[:login_type]
        end
        update_latlong(user, params[:latitude], params[:longitude])
        if user.userinfo
          info = user.userinfo
          render json: {STATUS_MSG: USER_INFO_FOUND, STATUS_CODE: OK_STATUS_CODE, user_token: user.authentication_token,
                        user_email: email, name: user.name, image_id: user.image_id, image_no: user.image_no, gender: info.gender, height: info.height,
                        ethnicity: info.ethnicity, body_type: info.body_type, relation_status: info.relation_status,
                        interested_in: info.interested_in, about_me: info.about_me, wingle_id: info.wingle_id, city: info.city,
                        country: info.country, headline: info.headline, address: info.address, birthday: info.birthday, id: user.id, nsetting: nsetting}
        else
          render json: {STATUS_MSG: NO_USER_INFO, STATUS_CODE: OK_STATUS_CODE, user_token: user.authentication_token, user_email: email,
                        name: user.name, image_id: user.image_id, image_no: user.image_no, gender: nil, height: nil,
                        ethnicity: nil, body_type: nil, relation_status: nil,
                        interested_in: nil, about_me: nil, wingle_id: nil, city: nil,
                        country: nil, headline: nil, address: nil, birthday: nil, id: user.id, nsetting: nsetting}
        end
      else
        render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE, user_token: nil, user_email: nil}
      end
    else
      login_type = params[:login_type]
      if params[:name].present?
        name = params[:name]
      else
        name = ""
      end

      newUser = User.new;
      newUser.email = email;
      newUser.name = name;
      newUser.login_type = login_type
      newUser.password = password;
      token = newUser.authentication_token;
      if newUser.save
        nsetting = Nsetting.new
        nsetting.user_id = newUser.id
        nsetting.save

        update_latlong(newUser, params[:latitude], params[:longitude])
        render json: {STATUS_CODE: OK_STATUS_CODE, user_token: newUser.authentication_token, user_email: newUser.email, STATUS_MSG: NO_USER_INFO, id: newUser.id, nsetting: nsetting}
      else
        render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE, user_token: nil, user_email: nil}
      end
    end
  end

  def full_profile
    Geocoder::Calculations.distance_between([47.858205, 2.294359], [40.748433, -73.985655])
  end

  def search_with_wingle_id
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])
    searched_user_ids = Userinfo.where(:wingle_id => params[:wingle_id]).pluck(:user_id)
    if searched_user_ids.empty?
      render json: {STATUS_CODE: NOT_FOUND_STATUS_CODE, user_id: nil, user_email: nil, user_name: nil, wingle_id: nil, image_id: nil}
    else
      searched_user = User.find(searched_user_ids[0])
      render json: {STATUS_CODE: OK_STATUS_CODE, user_id: searched_user.id,
                    user_email: searched_user.email, user_name: searched_user.name, wingle_id: params[:wingle_id], image_id: searched_user.image_id}
    end

  end

  def search_with_email_id
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])
    searched_user = User.find_by_email(params[:email_id])
    if searched_user
      render json: {STATUS_CODE: OK_STATUS_CODE, user_id: searched_user.id,
                    user_email: searched_user.email, user_name: searched_user.name, image_id: searched_user.image_id}
    else
      render json: {STATUS_CODE: NOT_FOUND_STATUS_CODE, user_id: nil, user_email: nil, user_name: nil, image_id: nil}
    end
  end

  def invite
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])
    InviteMailer.invit_email(params[:email_to]).deliver
    render json: {STATUS_CODE: OK_STATUS_CODE}
  end

  def reset_password
    user = User.find_by_email(params[:user_email])
    if user && user.resettoken == params[:resettoken]
      user.password = params[:password]
      user.resettoken = nil
      user.save
    else
      return render json: {STATUS_CODE: CONFLICT_STATUS_CODE}
    end

    render json: {STATUS_CODE: OK_STATUS_CODE}
  end

  def reset_password_token
    user = User.find_by_email(params[:user_email])
    if user && user.login_type == "email"
      user.resettoken = (0...8).map { ('a'..'z').to_a[rand(26)] }.join
      user.save
    else
      return render json: {STATUS_CODE: FORBIDDEN_STATUS_CODE}
    end

    PwdResetMailer.reset_token(params[:user_email], user.resettoken).deliver
    render json: {STATUS_CODE: OK_STATUS_CODE}
  end

  def set_gcm_token
    user = User.find_by_email(params[:user_email])
    if !user || params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])
    user.gcm_token = params[:gcm_token]
    user.save
    render json: {STATUS_CODE: OK_STATUS_CODE, STATUS_MSG: C::SUCCESS_STATUS_MSG}
  end

  def test_gcm
    data = {
        :title => "New Msg",
        :body => "Chat Msg ",
        :sender_id => "sender_id",
        :receiver_id => "receiver_id"
    }
    send_gcm_message(data, ["dG1IqJV668M:APA91bHW9Fr17CMHKzzPVOvEx6-hrXUcgrRvC7qjxzvZiv5cW4XaWNwbCg8yAgN8c1MrQRBzDgx7gD87-9jJbGdNyjeJZC4wnjBKarvsTjxvJzwjydxAyhfCofXGM11JyDQaKhgKocC9","c-Vm5OpwHf4:APA91bEFf_B_nAYGV9fIuVY_A6IcswJ7AzKTvq5QkLP_jgeGzaR0xqhFU0AUYN_FY6UBk2pgEZD1a4nemR78Rp0g219SNOpEiWdSHCGN3WZPSyBmKWCVgK4uzhYMJCMLtVD0yMFHW9yw"])

  end

  def get_user
    user = User.find_by_email(params[:user_email])

    public_user = User.find(params[:user_id])
    if user.favourites.where(:fav_user_id => public_user.id).present?
      is_favourite = true
    else
      is_favourite = false
    end

    if user.blockeds.where(:blocked_user_id => public_user.id).present?
      is_blocked = true
    else
      is_blocked = false
    end
    public_user.authentication_token = nil

    if user.latitude != 0 && user.longitude != 0 && public_user.latitude != 0 && public_user.longitude != 0 && public_user.nsetting.show_my_location == true
      distance = Geocoder::Calculations.distance_between([user.latitude,user.longitude], [public_user.latitude,public_user.longitude]).round(3)
      # distance = Geocoder::Calculations.distance_between([47.858205,2.294359], [40.748433,-73.985655]).round(1)
    else
      distance = "Unknown"
    end

    last_seen_before_mins = ((Time.now - public_user.last_sign_in_at) / 1.minute).round
    age = ((Time.now - public_user.userinfo.birthday) / 1.year).round

    if public_user.gcm_token
      get_notifications_msgs_count(public_user)
      data = {
          :gcm_type => C::Notifications::TYPE[:checkout],
          :unseen_notifications_count => @unseen_notifications_count,
          :all_notifications_count => @all_notifications_count,
          :unseen_msgs_total => @unseen_msgs_total,
          :user_name => user.name,
          :notification_type => C::Notifications::TYPE[:checkout],
          :user_id => user.id,
          :receiver_id => public_user.id
      }
      reg_tokens = [public_user.gcm_token]
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
    public_user.gcm_token = nil

    if public_user.userinfo
      return render json: {is_favourite: is_favourite, user: public_user, user_info: public_user.userinfo,
        last_seen_before_mins: last_seen_before_mins, age: age, distance: distance, is_blocked: is_blocked}
    else
      return render json: {is_favourite: is_favourite, user: public_user,
        last_seen_before_mins: last_seen_before_mins, age: age, distance: distance, is_blocked: is_blocked}
    end
  end

  def send_gcm_message(data, reg_tokens)
    require 'rest-client'

    # data = {
    #     :title => "title2",
    #     :body => "body",
    #     :anything => "foobar"
    # }

    post_args = {
        # :to field can also be used if there is only 1 reg token to send
        :registration_ids => reg_tokens,
        :data => data
    }

    begin
      # Send the request with JSON args and headers
      response = RestClient.post 'http://gcm-http.googleapis.com/gcm/send', post_args.to_json,
                      :Authorization => 'key=' + C::AUTHORIZE_KEY, :content_type => :json, :accept => :json
      return render json: {STATUS_CODE: OK_STATUS_CODE, STATUS_MSG: C::SUCCESS_STATUS_MSG, response: response}
    rescue Exception => e
      puts "=========Exception starts==========="
      puts e.message.inspect
      puts "---json Exception ends-----"
      return render json: {STATUS_CODE: C::INTERNAL_SERVER_ERROR_STATUS_CODE, EXCEPTION_MSG: e.message.inspect}
    end
  end

end
