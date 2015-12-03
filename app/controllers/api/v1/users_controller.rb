class Api::V1::UsersController < Api::V1::BaseController
  # before_action :authenticate_user!

	def index
	end

	def getAuthToken
		var token = Devise.friendly_token
	end
end