class HackingTeamsController < ApplicationController
  def index
    # Querying all hacking teams, but putting current user's team first
    teams_table = HackingTeam.arel_table
    order_clause = Arel::Nodes::Case.new(teams_table[:id])
      .when(current_user&.hacking_team_id).then(0)
      .else(1)
      .asc

    @teams = HackingTeam.order(order_clause).order(created_at: :desc).all

    authorize @teams
  end

  def new
    @team = HackingTeam.new
    authorize @team
  end

  def create
    @team = HackingTeam.new(team_params)
    authorize @team
    if @team.save
      current_user.update(hacking_team: @team)
      redirect_to hacking_teams_path
    else
      render :new
    end
  end

  def show
    @team = HackingTeam.find(params[:id])
    authorize @team

    @pending_applications = @team.join_applications.pending
    @rejected_applications = @team.join_applications.declined

    @current_user_application = JoinApplication.find_by(user: current_user, hacking_team: @team)

    @already_applied = @current_user_application&.pending?
    @already_rejected = @current_user_application&.declined?
  end

  def apply
    @team = HackingTeam.find(params[:hacking_team_id])
    authorize @team

    return redirect_to @team, notice: "You are already a member of a team." if current_user.hacking_team==@team

    application = JoinApplication.find_or_initialize_by(user: current_user, hacking_team: @team)

    if application.declined?
      redirect_to @team, alert: "You have already been declined from this team, and can't re-apply. Please contact someone of the team in-person if you want this decision to be revised."
    elsif application.update(state: :pending, decided_by_id: nil, decided_at: nil)
      redirect_to @team, notice: "Your application has been submitted."
    else
      redirect_to hacking_teams_path, alert: "Failed to submit your application."
    end
  end

  def accept
    @team = HackingTeam.find(params[:hacking_team_id])
    authorize @team


    application = JoinApplication.find(params[:id])
    return redirect_to @team, alert: "The user has already been accepted to another team." if application.user.hacking_team.present? && application.user.hacking_team != @team

    application.accept!(current_user)
    redirect_to @team, notice: "Application from #{application.user.decorate.readable_name} has been accepted."
  end

  def reject
    @team = HackingTeam.find(params[:hacking_team_id])
    authorize @team

    application = JoinApplication.find(params[:id])
    application.decline!(current_user)

    redirect_to @team, notice: "Application from #{application.user.decorate.readable_name} has been rejected."
  end

  def unreject
    @team = HackingTeam.find(params[:hacking_team_id])
    authorize @team

    application = JoinApplication.find(params[:id])

    if application.update(state: :pending, decided_at: nil, decided_by_id: nil)
      redirect_to @team, notice: "Application from #{application.user.decorate.readable_name} is back in the pending list."
    else
      redirect_to @team, alert: "Failed to un-reject the application: #{application.errors.full_messages.to_sentence}"
    end
  end

  def leave
    @team = HackingTeam.find(params[:hacking_team_id])
    authorize @team

    current_user.update(hacking_team: nil)
    redirect_to hacking_teams_path, notice: "You have successfully left the #{@team.name} team."
  end

  def kick
    @team = HackingTeam.find(params[:hacking_team_id])
    authorize @team

    user = User.find(params[:id])
    application = JoinApplication.find_by(user: user, hacking_team: @team)
    if user.update(hacking_team: nil) && application.update(state: :declined, decided_by: current_user, decided_at: Time.current)
      redirect_to @team, notice: "#{user.decorate.readable_name} has been kicked from the team."
    else
      redirect_to @team, alert: "Failed to kick the user: #{user.errors.full_messages.to_sentence} #{application.errors.full_messages.to_sentence}"
    end
  end

  private
  def team_params
    params.require(:hacking_team).permit(:name, :agenda)
  end
end
