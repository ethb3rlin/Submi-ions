class ApplicationController < ActionController::Base
  include Pundit::Authorization
  after_action :verify_authorized, except: :index

  protect_from_forgery with: :exception
  helper_method :current_user

  private
  def current_user
    @_current_user ||= session[:eth_address] &&
      EthereumAddress.find_by(address: session[:eth_address]).try(:user)
  end
end
