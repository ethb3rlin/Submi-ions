class HackingTeamsController < ApplicationController
  def index

    @teams = if current_user
      # Querying all hacking teams, but putting the ones for which JoinApplication with status "approved" exists first
      teams_table = HackingTeam.arel_table
      order_clause = Arel.sql("CASE WHEN EXISTS (SELECT 1 FROM join_applications WHERE hacking_team_id = hacking_teams.id AND user_id = ? AND state = 'approved') THEN 0 ELSE 1 END", current_user.id)
      HackingTeam.all.order(order_clause)
    else
      HackingTeam.all
    end.order(created_at: :desc).all
    @approved_application_ids = JoinApplication.approved.where(user: current_user).pluck(:hacking_team_id)
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
      current_user.hacking_teams << @team unless current_user.organizer?
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
    @already_rejected = @current_user_application&.declined? && (@current_user_application.decided_by != current_user)
  end

  def edit
    @team = HackingTeam.find(params[:id])
    authorize @team
  end

  def update
    @team = HackingTeam.find(params[:id])
    authorize @team

    if @team.update(team_params)
      redirect_to @team
    else
      redirect_to @team, alert: "Failed to update the team: #{@team.errors.full_messages.to_sentence}"
    end
  end

  def apply
    @team = HackingTeam.find(params[:hacking_team_id])
    authorize @team

    return redirect_to @team, notice: "You are already a member of a team." if current_user.hacking_teams.include?(@team)

    application = JoinApplication.find_or_initialize_by(user: current_user, hacking_team: @team)

    if application.declined? && (application.decided_by != current_user)
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
    return redirect_to @team, alert: "The user can't be added to any more teams." unless (application.user.hacking_teams.count < 2 || current_user.organizer?)

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

    JoinApplication.where(user: current_user, hacking_team: @team).update(state: :declined, decided_by: current_user, decided_at: Time.current) # TODO "left" should be a separate state
    redirect_to hacking_teams_path, notice: "You have successfully left the #{@team.name} team."
  end

  def kick
    @team = HackingTeam.find(params[:hacking_team_id])
    authorize @team

    user = User.find(params[:id])
    application = JoinApplication.find_or_create_by(user: user, hacking_team: @team)
    if application.update(state: :declined, decided_by: current_user, decided_at: Time.current)
      redirect_to @team, notice: "#{user.decorate.readable_name} has been kicked from the team."
    else
      redirect_to @team, alert: "Failed to kick the user: #{application.errors.full_messages.to_sentence}"
    end
  end


  ### Admin-only actions
  def admin_members
    @team = HackingTeam.find(params[:hacking_team_id])
    authorize @team
    @members = @team.hackers.decorate
    @all_other_hackers = User.hacker.where.not(id: @members.pluck(:id)).order(:name).decorate
  end

  def force_add
    @team = HackingTeam.find(params[:hacking_team_id])
    authorize @team

    new_hacker_id = params[:new_hacker].split(':').first.to_i
    new_hacker = User.find(new_hacker_id)
    JoinApplication.find_or_create_by(user: new_hacker, hacking_team: @team).accept!(current_user)
    redirect_to hacking_team_admin_members_path(@team), notice: "#{new_hacker.decorate.readable_name} has been added to the team."
  end

  private
  def team_params
    params.require(:hacking_team).permit(:name, :agenda)
  end
end
