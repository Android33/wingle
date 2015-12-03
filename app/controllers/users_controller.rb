class UsersController < ApplicationController
  before_action :authenticate_user!

	def index
	end

  def favorite_churches
    @favorites = current_user.favorites.all
    respond_to do |format|
      format.html
      format.json { render json: @favorites }
    end
  end
  
	def getAuthToken
		var token = Devise.friendly_token
	end
end