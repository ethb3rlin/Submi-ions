class VotesController < ApplicationController
  before_action :set_vote, only: %i[ update destroy ]

  def create
    @vote = Vote.new(vote_params)
    authorize @vote
    @vote.save!
  end

  def update
    @vote.update!(vote_params)
  end

  def destroy
    @vote.destroy!
    redirect_to votes_url, notice: "Vote was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vote
      @vote = Vote.find(params[:id])
      authorize @vote
    end

    # Only allow a list of trusted parameters through.
    def vote_params
      params.require(:vote).permit(:mark, :completed)
    end
end
