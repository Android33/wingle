module UsersHelper

  def update_latlong(user_email, lat, lon)
    user = User.find_by_email(user_email)
    user.last_sign_in_at = Time.now
    user.latitude = lat
    user.longitude = lon
    user.save
    # return :json => true
    return user
  end
end
