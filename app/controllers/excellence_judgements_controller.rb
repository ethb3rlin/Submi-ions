class ExcellenceJudgementsController < ApplicationController
  def index
    @team = if current_user.judge? && Setting.hackathon_stage == :judging
      current_user.excellence_team
    else
      ExcellenceTeam.find_by(track: params[:track] || Submission::HUMAN_READABLE_EXCELLENCE_TRACKS.keys.first)
    end

    @submissions = Submission.where(excellence_award_track: @team.track).includes(:excellence_judgements).order(created_at: :desc)
    authorize ExcellenceJudgement

    if %i[finalizing published].include?(Setting.hackathon_stage)
      @submissions = @submissions.sort_by { |s| -s.excellence_judgements.sum(&:score) }
    end

    @teammates = @team.users.order(:name)
    if current_user.judge? && Setting.hackathon_stage == :judging
      @teammates = @teammates.where.not(id: current_user.id)
    end
    @teammates = @teammates.decorate
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
