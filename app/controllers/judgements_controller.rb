class JudgementsController < ApplicationController
  def index
    @judging_team = current_user.judging_team

    @judgements = Judgement.where(judging_team: @judging_team).order(:created_at)
    authorize @judgements

    @there_are_more_to_judge = Submission.unassigned.any?
  end

  def create
    @judging_team = current_user.judging_team

    @submission = Submission.unassigned.first

    @judgement = Judgement.new(submission: @submission, judging_team: @judging_team)
    authorize @judgement

    @judgement.technical_vote = Vote.create!(user: @judging_team.technical_judge, mark: 50)
    @judgement.product_vote = Vote.create!(user: @judging_team.product_judge, mark: 50)
    @judgement.concept_vote = Vote.create!(user: @judging_team.concept_judge, mark: 50)
    @judgement.save!

    redirect_to @judgement
  end

  def show
    @judgement = Judgement.find(params[:id])
    authorize @judgement

    @judgement.initialize_votes!

    @judging_team = @judgement.judging_team
    @submission = @judgement.submission
  end

  def complete
    @judgement = Judgement.find(params[:id])
    authorize @judgement

    @judgement.complete_for(current_user)

    if @judgement.completed?
      if @judgement.judging_team.current_judgement.present?
        redirect_to judgement_path(current_user.judging_team.current_judgement)
      else
        redirect_to judgements_path
      end
    else
      redirect_to @judgement
    end
  end
end
