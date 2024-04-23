class JudgementsController < ApplicationController
  def index
    @judging_team = current_user.judging_team

    @judgements = Judgement.where(judging_team: @judging_team).order(:created_at)
    authorize @judgements

    if @judging_team.present? && @judging_team.current_judgement.present? && !@judging_team.current_judgement.completed?
      redirect_to @judging_team.current_judgement
    end

    @there_are_more_to_judge = @judging_team.pending_submissions.any?
  end

  def create
    @judging_team = current_user.judging_team

    @submission = @judging_team.pending_submissions.first

    @judgement = Judgement.new(submission: @submission, judging_team: @judging_team)
    authorize @judgement

    return redirect_to judgements_path unless @judging_team.present? && @submission.present?
    return redirect_to @judging_team.current_judgement if @judging_team.current_judgement.present?

    @judgement.technical_vote = Vote.create!(user: @judging_team.technical_judge, mark: 50)
    @judgement.product_vote = Vote.create!(user: @judging_team.product_judge, mark: 50)
    @judgement.concept_vote = Vote.create!(user: @judging_team.concept_judge, mark: 50)
    @judgement.save!

    @judging_team.update(current_judgement: @judgement)

    redirect_to @judgement
  end

  def show
    @judgement = Judgement.find(params[:id])
    authorize @judgement

    @judging_team = @judgement.judging_team
    @submission = @judgement.submission
  end

  def complete
    @judgement = Judgement.find(params[:id])
    authorize @judgement

    @judgement.complete_for(current_user)

    if @judgement.completed?
      redirect_to judgements_path
    else
      redirect_to @judgement
    end
  end
end
