class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  private
  def current_user
    @_current_user ||= session[:eth_address] &&
      EthereumAddress.find_by(address: session[:eth_address]).try(:user)
  end
end
