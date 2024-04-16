class VotesController < ApplicationController
  before_action :set_vote, only: %i[ show edit update destroy ]

  # GET /votes or /votes.json
  def index
    current_vote = Vote.find_or_create_by!(user: current_user, submission_id: 1) # FIXME: submission_id should be a parameter

    @submission = current_vote.submission

    @votes = Vote.order(:id).all
    authorize @votes
  end

  # POST /votes or /votes.json
  def create
    @vote = Vote.new(vote_params)
    authorize @vote

    respond_to do |format|
      if @vote.save
        format.html { redirect_to vote_url(@vote), notice: "Vote was successfully created." }
        format.json { render :show, status: :created, location: @vote }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /votes/1 or /votes/1.json
  def update
    respond_to do |format|
      if @vote.update(vote_params.merge(completed: false))
        format.html { redirect_to vote_url(@vote), notice: "Vote was successfully updated." }
        format.json { render :show, status: :ok, location: @vote }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /votes/1 or /votes/1.json
  def destroy
    @vote.destroy!

    respond_to do |format|
      format.html { redirect_to votes_url, notice: "Vote was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def complete
    @vote = Vote.find(params[:id])
    authorize @vote
    @vote.update!(completed: true)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vote
      @vote = Vote.find(params[:id])
      authorize @vote
    end

    # Only allow a list of trusted parameters through.
    def vote_params
      params.require(:vote).permit(:mark)
    end
end
