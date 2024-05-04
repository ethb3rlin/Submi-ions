class Admin::SubmissionsController < ApplicationController
  def index
    @submissions = if params[:track].present? && Submission::HUMAN_READABLE_TRACKS[params[:track]].present?
      Submission.where(track: params[:track])
    else
      Submission.all
    end
    authorize @submissions

    @unassigned_count = Submission.unassigned.count
  end
end
