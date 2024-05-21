class Admin::ExcellenceTeamsController < ApplicationController
  def index
    authorize ExcellenceTeam
    @excellence_teams_by_track = {}.with_indifferent_access
    Submission::HUMAN_READABLE_EXCELLENCE_TRACKS.keys.each do |track| # There will be only three of them, so we're fine doing dumb iterations
      excellence_team = ExcellenceTeam.find_or_create_by(track: track)
      @excellence_teams_by_track[track] = excellence_team
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
