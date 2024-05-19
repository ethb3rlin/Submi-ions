require 'securerandom'

class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[ show edit update destroy ]

  skip_after_action :verify_authorized, only: %i[ index results show ]

  # GET /submissions or /submissions.json
  def index
    return redirect_to results_submissions_url if Setting.hackathon_stage == :published
    @submissions = Submission.includes(:hacking_team, :judgement).all
    authorize @submissions
  end

  def results
    @track = if params[:track].present? && Submission::HUMAN_READABLE_TRACKS[params[:track]].present?
      params[:track]
    else
      Submission::HUMAN_READABLE_TRACKS.keys.first
    end

    @submissions = Submission.where(track: @track).includes(:hacking_team, :judgement).joins(:judgement).where('judgements.no_show': false).order_by_total_score
    authorize @submissions
  end

  # GET /submissions/1 or /submissions/1.json
  def show
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
      @submission = Submission.find(params[:id]).decorate
      authorize @submission
    end

    # Only allow a list of trusted parameters through.
    def submission_params
      params.require(:submission).permit(:title, :description, :repo_url, :pitchdeck_url, :track)
    end
end
