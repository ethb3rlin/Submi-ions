class ExcellenceJudgementsController < ApplicationController
  def index
    @team = current_user.excellence_team || ExcellenceTeam.find_by(track: params[:track])
    @submissions = Submission.where(excellence_award_track: @team.track).includes(:excellence_judgements).order(created_at: :desc)
    authorize @submissions

    @teammates = @team.users.order(:name) - [current_user]
  end

  def show
  end

  def update
    @judgement = ExcellenceJudgement.find(params[:id])
    authorize @judgement
    @judgement.update!(score: params[:judgement][:score].to_f)

    head :ok
  end
end
