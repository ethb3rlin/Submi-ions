require 'securerandom'

class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[ show edit update destroy ]

  skip_after_action :verify_authorized, only: %i[ index results show ]

  # GET /submissions or /submissions.json
  def index
    @submissions = Submission.includes(:hacking_team, :judgement).order(created_at: :desc).all
    authorize @submissions
  end

  def results
    @results = {}
    Submission::HUMAN_READABLE_TRACKS.keys.each do |track|
      submissions = Submission.where(track: track).includes(:hacking_team, :judgement).joins(:judgement).where('judgements.no_show': false).order_by_total_score.limit(3)
      authorize submissions
      @results[track] = submissions
    end

    @excellence_awards = {}
    Submission::HUMAN_READABLE_EXCELLENCE_TRACKS.keys.each do |track|
      submission = Submission.order_by_excellence_score(track).first
      authorize submission if submission
      @excellence_awards[track] = submission
    end
  end

  # GET /submissions/1 or /submissions/1.json
  def show
    if policy(SubmissionComment).show?
      @new_comment = @submission.comments.build(user: current_user)
    end

    @published_submission = @submission.hacking_team.submissions.find_by(draft: false)
  end

  def publish
    @submission = Submission.with_drafts.find(params[:submission_id])
    authorize @submission

    Submission.transaction do
      @submission.update!(draft: false)
      @submission.hacking_team.submissions.where.not(id: @submission.id).update_all(draft: true, updated_at: DateTime.now) unless current_user.organizer?
    end
    redirect_to submission_url(@submission), notice: "Submission was successfully published."
  end

  def draft
    @submission = Submission.with_drafts.find(params[:submission_id])
    authorize @submission

    @submission.update!(draft: true)
    redirect_to submission_url(@submission), notice: "Submission was successfully drafted."
  end

  def add_comment
    @submission_comment = SubmissionComment.new(comment_params)
    authorize @submission_comment, :create?
    @submission_comment.save!
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
    authorize @submission
  end

  # GET /submissions/1/edit
  def edit
  end

  # POST /submissions or /submissions.json
  def create
    Submission.transaction do
      if current_user.hacking_teams.blank?
        name = current_user.name.present? ? "#{current_user.name}'s Team" : "Team \##{SecureRandom.hex(4)}"
        if HackingTeam.exists?(name: name)
          name = "#{name} \##{SecureRandom.hex(4)}"
        end
        current_user.hacking_teams.create!(name: name)
      end

      team = HackingTeam.find_by(id: params[:submission][:hacking_team]) || current_user.hacking_teams.last

      @submission = team.submissions.new(submission_params)
      authorize @submission

      published_submission = team.submissions.find_by(draft: false)
      if published_submission.present?
        @submission.draft = true
        flash[:alert] = "You have already published a '#{published_submission.title}' submission. This project will be saved as a draft. You can change which one is published at any moment while the hackathon is still ongoing — but you will only be judged on a single published submission."
      end


      if @submission.save
        redirect_to submission_url(@submission), notice: "Submission #{@submission.title} was successfully created."
      else
        redirect_to new_submission_url, alert: "Submission could not be created: #{@submission.errors.full_messages.to_sentence}"
      end
    end
  end

  # PATCH/PUT /submissions/1 or /submissions/1.json
  def update
    if @submission.update(submission_params)
      redirect_to submission_url(@submission), notice: "Submission was successfully updated."
    else
      redirect_to edit_submission_url(@submission), alert: "Submission could not be updated: #{submission.errors.full_messages.to_sentence}"
    end
  end

  # DELETE /submissions/1 or /submissions/1.json
  def destroy
    @submission.destroy!
    redirect_to submissions_url, notice: "Submission was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.with_drafts.find(params[:id]).decorate
      authorize @submission
    end

    # Only allow a list of trusted parameters through.
    def submission_params
      params.require(:submission).permit(:title, :description, :repo_url, :pitchdeck_url, :track, :excellence_award_track)
    end

    def comment_params
      params.require(:submission_comment).permit(:text).merge(user: current_user, submission_id: params[:submission_id])
    end
end
