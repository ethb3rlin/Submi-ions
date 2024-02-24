class Admin::SubmissionsController < ApplicationController
  def index
    @submissions = Submission.all
    authorize @submissions
  end
end
