class JudgementsController < ApplicationController
  def index
    @judging_team = current_user.judging_team

    @judgements = Judgement.with_no_show.where(judging_team: @judging_team).order(:created_at)
    authorize @judgements

    @there_are_more_to_judge = Submission.unassigned.any?
  end

  def create
    @judging_team = current_user.judging_team

    @submission = Submission.unassigned.first

    @judgement = Judgement.new(submission: @submission, judging_team: @judging_team)
    authorize @judgement

    Judgement.transaction do
      @judgement.technical_vote = Vote.create!(user: @judging_team.technical_judge, mark: 0)
      @judgement.product_vote = Vote.create!(user: @judging_team.product_judge, mark: 0)
      @judgement.concept_vote = Vote.create!(user: @judging_team.concept_judge, mark: 0)
      @judgement.save!
    end

    redirect_to @judgement
  end

  def show
    @judgement = Judgement.with_no_show.find(params[:id])
    authorize @judgement

    @judgement.initialize_votes!

    @judging_team = @judgement.judging_team
    @submission = @judgement.submission

    @new_comment = @judgement.comments.build(user: current_user)
  end

  def add_comment
    @judgement_comment = JudgementComment.new(comment_params)
    authorize @judgement_comment, :create?
    @judgement_comment.save!
  end

  def no_show # Don't get confused, this is an action which sets the no_show flag to true
    @judgement = Judgement.find(params[:id])
    authorize @judgement

    @judgement.mark_as_no_show!

    if @judgement.judging_team.current_judgement.present?
      redirect_to judgement_path(current_user.judging_team.current_judgement)
    else
      redirect_to judgements_path
    end
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

  private
  def comment_params
    params.require(:judgement_comment).permit(:text).merge(user: current_user, judgement_id: params[:id])
  end
end
