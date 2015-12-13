class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def getAuthToken
    var token = Devise.friendly_token
  end
end
