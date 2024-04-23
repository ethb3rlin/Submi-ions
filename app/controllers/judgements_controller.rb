class JudgementsController < ApplicationController
  def index
    @judgements = Judgement.where(judging_team: current_user.judging_team)
    authorize @judgements

    if current_user.judging_team.present? && current_user.judging_team.current_judgement.present? && !current_user.judging_team.current_judgement.completed?
      redirect_to edit_judgement_path(current_user.judging_team.current_judgement)
    end
  end

  def create
    @judging_team = current_user.judging_team

    return redirect_to judgements_path unless @judging_team.present?
    return redirect_to edit_judgement_path(@judging_team.current_judgement) if @judging_team.current_judgement.present?

    @submission = Submission.left_outer_joins(:judgement).where(judgements: { id: nil }).first

    @judgement = Judgement.new(submission: @submission, judging_team: @judging_team)
    authorize @judgement

    @judgement.technical_vote = Vote.create!(user: @judging_team.technical_judge, mark: 50)
    @judgement.product_vote = Vote.create!(user: @judging_team.product_judge, mark: 50)
    @judgement.concept_vote = Vote.create!(user: @judging_team.concept_judge, mark: 50)
    @judgement.save!

    @judging_team.update(current_judgement: @judgement)

    redirect_to edit_judgement_path(@judgement)
  end

  def edit
    @judgement = Judgement.find(params[:id])
    authorize @judgement

    @judging_team = @judgement.judging_team
    @submission = @judgement.submission
  end
end