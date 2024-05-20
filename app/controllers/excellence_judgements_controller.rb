class ExcellenceJudgementsController < ApplicationController
  def index
    @submissions = Submission.where(excellence_award_track: current_user.excellence_team.track).includes(:excellence_judgements).order(created_at: :desc)
    authorize @submissions

    @teammates = current_user.excellence_team.users.order(:name) - [current_user]

    @team = current_user.excellence_team # TODO: load this from params if the user is Org
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
