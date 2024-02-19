class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    if request.env['omniauth.auth']
      flash[:notice] = "Logged in"
    else
      flash[:notice] = "Unable to log in"
    end

    redirect_to '/'
  end

  def index
    render inline: "<%= button_to 'Sign in', auth_ethereum_path, data: {turbo: false} %>", layout: true
  end
end
