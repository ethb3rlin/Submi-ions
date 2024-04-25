class HackingTeamsController < ApplicationController
  def index
    @teams = HackingTeam.all
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

  private
  def team_params
    params.require(:hacking_team).permit(:name, :agenda)
  end
end
