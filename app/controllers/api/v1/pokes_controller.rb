#if you want to authenticate your controller use below line of code
#class Api::V1::UsersController < Api::V1::BaseController
class Api::V1::PokesController < Api::V1::BaseController
  # before_action :authenticate_user!

  include UsersHelper

  def create
    user = update_latlong(params[:user_email], params[:latitude], params[:longitude])
    poke = user.pokes.new
    poke.poked_user_id = params[:poked_user_id]
    poke.save

    return render :json=> {status: 200, poked_user: poke}
  end
end
