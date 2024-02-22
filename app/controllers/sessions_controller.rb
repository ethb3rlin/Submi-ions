class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  skip_after_action :verify_authorized

  def create
    if request.env['omniauth.auth']
      session[:eth_address] = request[:eth_address]

      address = EthereumAddress.find_by(address: request[:eth_address])
      user = if address
        address.user
      else
        user = User.create
        address = EthereumAddress.create(address: request[:eth_address], user: user)
        user
      end

      flash[:notice] = "Logged in as user #{user.id}"
    else
      flash[:notice] = "Unable to log in"
    end

    redirect_to '/'
  end

  def destroy
    reset_session
    flash[:notice] = "Logged out"
    redirect_to '/'
  end
end
