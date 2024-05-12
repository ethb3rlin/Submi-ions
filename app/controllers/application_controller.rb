class ApplicationController < ActionController::Base
  before_action :prepare_for_login, if: -> { request.get? && current_user.nil? }

  rescue_from Exception, :with => :handle_exception unless Rails.env.development?

  include Pundit::Authorization
  after_action :verify_authorized

  protect_from_forgery with: :exception
  helper_method :current_user

  private
    def prepare_for_login
      nonce = SecureRandom.alphanumeric(12)
      session[:nonce] = nonce
      cookies[:nonce] = { value: nonce, httponly: false, secure: Rails.env.production? }

      # ISO 8601 in Z (UTC) format
      timestamp = DateTime.now.utc.iso8601
      session[:timestamp] = timestamp
      cookies[:timestamp] = { value: timestamp, httponly: false, secure: Rails.env.production? }
    end

    def current_user
      @_current_user ||= User.unscoped.joins(:ethereum_addresses).where(ethereum_addresses: { address: session[:address] }).first if session[:address]
      @_current_user.decorate if @_current_user
    end

    def handle_exception(exception)
      logger.error "Exception: #{exception.class.name} - #{exception.message}"

      flash.keep
      flash[:error] = "An error occurred: #{exception.message}"

      redirect_to root_path
    end
end
