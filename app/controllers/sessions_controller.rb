require 'siwe'

class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[sign_in]
  skip_after_action :verify_authorized # Doesn't make sense to authorize this controller

  # Not actually routed, but is required by verify_authorized
  def index
  end

  def sign_in
    message = Siwe::Message.from_message params.require(:message).gsub(/\r\n|\r|\n/, "\n").strip

    signature = params.require(:signature)
    nonce = session[:nonce]
    timestamp = session[:timestamp]

    domain = request.host
    port = request.port
    domain = "#{domain}:#{port}" unless port == 80 || port == 443
    protocol = request.protocol

    if message.verify(params.require(:signature), "#{domain}", message.issued_at, message.nonce)
      session[:nonce] = nil
      session[:timestamp] = nil

      cookies.delete :nonce
      cookies.delete :timestamp

      session[:address] = message.address

      address_record = EthereumAddress.find_or_create_by(address: message.address)
      Hacker.create(ethereum_addresses: [address_record]) unless address_record.user

      # Let's redirect with Javascript, otherwise cookies won't be set
      if address_record.user.organizer?
        render html: "<script>window.location = '/admin';</script>".html_safe
      else
        render html: "<script>window.location = '/';</script>".html_safe
      end
    else
      head :bad_request
    end
  end

  def sign_out
    if current_user
      current_user.save
      session[:address] = nil
      redirect_to root_path, notice: "You have been logged out."
    else
      head :unauthorized
    end
  end
end
