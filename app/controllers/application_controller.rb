class ApplicationController < ActionController::Base
  include Pundit::Authorization
  after_action :verify_authorized

  protect_from_forgery with: :exception
  helper_method :current_user

  private
  def current_user
    @_current_user ||= User.joins(:ethereum_addresses).where(ethereum_addresses: { address: session[:address] }).first if session[:address]
  end
end
