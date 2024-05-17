class Admin::SubmissionsController < ApplicationController
  def index
    @submissions = if params[:track].present? && Submission::HUMAN_READABLE_TRACKS[params[:track]].present?
      Submission.where(track: params[:track])
    else
      Submission.all
    end.includes(judgement: [:judging_team, :technical_vote, :product_vote, :concept_vote])
    authorize @submissions

    if Setting.hackathon_stage == :finalizing
      @submissions = @submissions.order_by_total_score
    end

    @unassigned_count = Submission.unassigned.count
  end
end
