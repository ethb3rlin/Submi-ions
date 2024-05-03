class Admin::SubmissionsController < ApplicationController
  def index
    @submissions = Submission.all
    authorize @submissions

    @unassigned_count = Submission.unassigned.count
  end
end
