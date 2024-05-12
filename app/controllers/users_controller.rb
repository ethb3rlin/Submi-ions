class UsersController < ApplicationController
  skip_after_action :verify_authorized, only: [:home]

  def home
    return redirect_to submissions_path unless current_user
    return redirect_to edit_user_path(current_user) unless current_user.approved?
    return redirect_to admin_root_path if current_user.organizer?
    return redirect_to judgements_path if current_user.judge?

    @teams = current_user.hacking_teams
    @current_team = HackingTeam.find_by(id: params[:team_id]) || @teams.first
    @submissions = @current_team.submissions.order(created_at: :desc) rescue []
  end

  def edit
    @user = User.unscoped.find(params[:id])
    authorize @user
  end

  def verify_zupass_credentials
    @user = User.unscoped.find(params[:id])
    authorize @user

    background_checker_url = ENV.fetch('ZUPASS_CHECKER_URL', 'localhost:8000')
    response = HTTParty.post(background_checker_url, json: request.body.read, headers: { 'Content-Type' => 'application/json' })

    if response.code == 200
      @user.update!(approved_at: DateTime.now)
      # TODO: invalidate TicketID here, so the single claim won't authorize multiple accounts
      redirect_to root_path
    else
      render :edit, alert: 'There was an error verifying your credentials. Please try again.'
    end
  end

  def update
    @user = User.unscoped.find(params[:id])
    authorize @user

    if @user.update(user_params)
      redirect_to root_path
    else
      render :edit, alert: 'There was an error updating your profile: ' + @user.errors.full_messages.join(', ')
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
