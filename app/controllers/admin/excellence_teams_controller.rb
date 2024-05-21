class Admin::ExcellenceTeamsController < ApplicationController
  def index
    @excellence_teams = ExcellenceTeam.order(:id).includes(:users).all
    authorize @excellence_teams
    @excellence_teams_by_track = {}.with_indifferent_access
    @excellence_teams.each do |excellence_team| # There will be only three of them, so we're fine doing dumb iterations
      @excellence_teams_by_track[excellence_team.track] = excellence_team
    end

    @potential_judges = User.unassigned_judges.order(:name)
  end

  def add_user
    membership = ExcellenceTeamMembership.new(user_id: params[:user][:user_id], excellence_team_id: params[:excellence_team_id])
    authorize membership
    membership.save!

    redirect_to admin_excellence_teams_path
  end

  def remove_user
    membership = ExcellenceTeamMembership.find_by(user_id: params[:user_id], excellence_team_id: params[:excellence_team_id])
    authorize membership
    membership.destroy!

    redirect_to admin_excellence_teams_path
  end
end
