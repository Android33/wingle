#if you want to authenticate your controller use below line of code
#class Api::V1::UsersController < Api::V1::BaseController
class Api::V1::UsersController < ApplicationController
  # before_action :authenticate_user!

  include UsersHelper
  # include c

  def index
  end

  def getAuthToken
    var token = Devise.friendly_token
  end

  def near_users

    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])

    latitude = params[:latitude]
    longitude = params[:longitude]
    #    distance = params[:distance]
    #    hardcode distance 50 km
    distance = 50
    users = User.near([latitude, longitude], distance, :order => "distance")
    users = users.where.not(:id => user.id)

    users_array = []

    users && users.each do |near_user|
      minutes = ((Time.now - near_user.last_sign_in_at) / 1.minute).round
      user_object = {}
      if minutes < 10
        user_object["is_online"] = true
      else
        user_object["is_online"] = false
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
      puts "inside distance 0"
    else
      users = User.near([latitude, longitude], distance, :order => "distance")
    end

    users = users.where.not(:id => user.id)
    # puts "users: #{users.count}"
    users_array = []
    users && users.each do |near_user|
      user_object = {}
      puts "name: #{near_user.name}"
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
        puts "user_info.city: #{user_info.city} city: #{city}"
        # Equal ignore case syntax city.casecmp(user_info.city).zero? will return true when strings equal
        next if !city.casecmp(user_info.city).zero?

        # Means both parameters exists age and city
      elsif age_city == 3 && user_info.birthday && user_info.city
        user_age = ((Time.now - user_info.birthday) / 1.year).round
        puts "age: #{age.to_i.class} user_age: #{user_age.class}"
        next if age.to_i != user_age
        puts "after next age: #{age.to_i.class} user_age: #{user_age.class}"

        puts "before user_info.city: #{user_info.city} city: #{city}"
        next if !city.casecmp(user_info.city).zero?
        puts "after user_info.city: #{user_info.city} city: #{city}"
      end

      puts "after checks"

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

  def login_signup
    puts params.inspect
    email = params[:user_email]
    password = params[:user_password]

    user = User.find_by_email(email)
    token = nil
    if user
      if user.valid_password?(password)
        puts "inside valid password"
        update_latlong(user, params[:latitude], params[:longitude])
        if user.userinfo
          info = user.userinfo
          render json: {STATUS_MSG: USER_INFO_FOUND, STATUS_CODE: OK_STATUS_CODE, user_token: user.authentication_token,
                        user_email: email, name: user.name,image_id: user.image_id,image_no: user.image_no, gender: info.gender, height: info.height,
                        ethnicity: info.ethnicity, body_type: info.body_type, relation_status: info.relation_status,
                        interested_in: info.interested_in, about_me: info.about_me, wingle_id: info.wingle_id, city: info.city,
                        country: info.country, zipcode: info.zipcode, address: info.address, birthday: info.birthday, id: user.id}
        else
          render json: {STATUS_MSG: NO_USER_INFO, STATUS_CODE: OK_STATUS_CODE, user_token: user.authentication_token, user_email: email,
                        name: user.name,image_id: user.image_id,image_no: user.image_no, gender: nil, height: nil,
                        ethnicity: nil, body_type: nil, relation_status: nil,
                        interested_in: nil, about_me: nil, wingle_id: nil, city: nil,
                        country: nil, zipcode: nil, address: nil, birthday: nil, id:user.id}
        end
      else
        render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE, user_token: nil, user_email: nil}
      end
    else
      login_type = params[:login_type]
      puts "inside new"
      name = params[:name]
      newUser = User.new;
      newUser.email = email;
      newUser.name = name;
      newUser.password = password;
      token = newUser.authentication_token;
      if newUser.save
        update_latlong(newUser, params[:latitude], params[:longitude])
        render json: {STATUS_CODE: OK_STATUS_CODE, user_token: newUser.authentication_token, user_email: newUser.email, STATUS_MSG: NO_USER_INFO, id: newUser.id}
      else
        render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE, user_token: nil, user_email: nil}
      end
    end
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
                    user_email: searched_user.email, user_name: searched_user.name, wingle_id: params[:wingle_id],image_id: searched_user.image_id}
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

  def set_gcm_token
    user = User.find_by_email(params[:user_email])
    if params[:user_token] != user.authentication_token
      return render json: {STATUS_CODE: UNAUTHORIZED_STATUS_CODE}
    end
    update_latlong(user, params[:latitude], params[:longitude])
    user.gcm_token = params[:gcm_token]
    user.save
    render json: {STATUS_CODE: OK_STATUS_CODE, STATUS_MSG: C::SUCCESS_STATUS_MSG}
  end

  def test_gcm
    send_gcm_message("title", "body", "cGLdhej3-Rk:APA91bEbLW0tDg8_e_rwniFThdyBf2446liMUJKlD1hUM7Ram38shCYhFIG14JCimTpO0D3PBC75PcuPl64MI2d8IkqaIjFBCWzme7siWcxi-gnV1dTbE7yr6TUmmaN7V2fcBDp8oFpX")

  end


  def send_gcm_message(title, body, reg_tokens)
    require 'rest-client'
    # Construct JSON payload
    post_args = {
        # :to field can also be used if there is only 1 reg token to send
        :registration_ids => reg_tokens,
        :data => {
            :title => title,
            :body => body,
            :anything => "foobar"
        }
    }

    # Send the request with JSON args and headers
    RestClient.post 'http://gcm-http.googleapis.com/gcm/send', post_args.to_json,
                    :Authorization => 'key=' + C::AUTHORIZE_KEY, :content_type => :json, :accept => :json
    render json: {STATUS_CODE: OK_STATUS_CODE, STATUS_MSG: C::SUCCESS_STATUS_MSG}

    #  require 'gcm'
    #
    #     gcm = GCM.new(C::AUTHORIZE_KEY)
    # # you can set option parameters in here
    # #  - all options are pass to HTTParty method arguments
    # #  - ref: https://github.com/jnunemaker/httparty/blob/master/lib/httparty.rb#L40-L68
    # #  gcm = GCM.new("my_api_key", timeout: 3)
    #
    #     registration_ids= [ "cGLdhej3-Rk:APA91bEbLW0tDg8_e_rwniFThdyBf2446liMUJKlD1hUM7Ram38shCYhFIG14JCimTpO0D3PBC75PcuPl64MI2d8IkqaIjFBCWzme7siWcxi-gnV1dTbE7yr6TUmmaN7V2fcBDp8oFpX"] # an array of one or more client registration IDs
    #     options = {data: {score: "123"}, collapse_key: "updated_score"}
    #     response = gcm.send(registration_ids, options)
  end

  def test
    require 'rest-client'
    RestClient.post("http://graph.facebook.com/799275336836642/picture?type=large", :param => nil) do |response, request, result, &block|
      if [301, 302, 307].include? response.code
        redirected_url = response.headers[:location]
        puts redirected_url
      else
        response.return!(request, result, &block)
      end
    end
    render json: {STATUS_CODE: OK_STATUS_CODE}
  end

end
