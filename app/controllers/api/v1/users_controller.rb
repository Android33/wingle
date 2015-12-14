#if you want to authenticate your controller use below line of code
#class Api::V1::UsersController < Api::V1::BaseController
class Api::V1::UsersController < ApplicationController
  # before_action :authenticate_user!

  include UsersHelper

  def index
  end

  def getAuthToken
    var token = Devise.friendly_token
  end

  def near_users

    user = update_latlong(params[:user_email], params[:latitude], params[:longitude])

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

      if user.favourites.where(:fav_user_id => near_user.id).count > 0
        user_object["is_favourite"] = true
      else
        user_object["is_favourite"] = false
      end
      users_array << user_object
    end

    return render :json => {status: 200, users: users_array}
  end

  def filter_users

    user = update_latlong(params[:user_email], params[:latitude], params[:longitude])

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

    if !distance || distance == 0
      users = User.all
    else
      users = User.near([latitude, longitude], distance, :order => "distance")
    end

    users = users.where.not(:id => user.id)
    users_array = []
    flag = true
    users && users.each do |near_user|
      user_object = {}
      # Means only age parameter exists not the city
      if age_city == 1
        user_info = users.find(near_user.id).user_info
        if user_info
          if user_info.birthday
            user_age = ((Time.now - user_info.birthday) / 1.year).round
            puts "age: #{age} user_age: #{user_age}"
            next if age != user_age
          end
        else
          next
        end


        # Means only city parameter exists not the age
      elsif age_city == 2
        user_info = users.find(near_user.id).user_info
        if user_info
          puts "user_info.city: #{user_info.city} city: #{city}"
          # Equal ignore case syntax city.casecmp(user_info.city).zero? will return true when strings equal
          next if user_info.city && !city.casecmp(user_info.city).zero?
        else
          next
        end

        # Means both parameters exists age and city
      elsif age_city == 3
        user_info = users.find(near_user.id).user_info
        if user_info
          if user_info.birthday
            user_age = ((Time.now - user_info.birthday) / 1.year).round
            puts "age: #{age.to_i.class} user_age: #{user_age.class}"
            next if age.to_i != user_age
            puts "after next age: #{age.to_i.class} user_age: #{user_age.class}"
          end
          puts "before user_info.city: #{user_info.city} city: #{city}"
          next if user_info.city && !city.casecmp(user_info.city).zero?
          puts "after user_info.city: #{user_info.city} city: #{city}"
        else
          next
        end
      else
        next
      end

      puts "after checks"

      minutes = ((Time.now - near_user.last_sign_in_at) / 1.minute).round
      if minutes < 10
        user_object["is_online"] = true
      else
        user_object["is_online"] = false
      end
      user_object["id"] = near_user.id
      user_object["name"] = near_user.name
      user_object["surname"] = near_user.surname

      if user.favourites.where(:fav_user_id => near_user.id).count > 0
        user_object["is_favourite"] = true
      else
        user_object["is_favourite"] = false
      end
      users_array << user_object
    end


    return render :json => {status: 200, users: users_array}
  end

  def login_signup
    puts params.inspect
    email = params[:user_email]
    password = params[:user_password]

    user = User.find_by_email(email)
    token = nil
    if user
      if user.valid_password?(password)
        render json: {status: 200, user_token: user.authentication_token, user_email: email, login_signup: "login"}
      else
        render json: {status: 401, user_token: nil, user_email: nil}
      end
    else
      puts "Email already exists"
      login_type = params[:login_type]
      newUser = User.new;
      newUser.email = email;
      newUser.password = password;
      token = newUser.authentication_token;
      puts "email: #{newUser.email}"
      if newUser.save
        render json: {status: 200, user_token: newUser.authentication_token, user_email: newUser.email, login_signup: "signup"}
      else
        render json: {status: 401, user_token: "nil", user_email: "Email already exists"}
      end
    end
  end

end
