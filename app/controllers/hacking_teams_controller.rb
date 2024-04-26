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
  end

  private
  def team_params
    params.require(:hacking_team).permit(:name, :agenda)
  end
end
