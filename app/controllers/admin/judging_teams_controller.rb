class Admin::JudgingTeamsController < ApplicationController
  def index
    @judging_teams = JudgingTeam.order(:id).all
    authorize @judging_teams
  end

  def new
    @judging_team = JudgingTeam.new
    authorize @judging_team

    @judges = User.unassigned_judges + [@judging_team.technical_judge, @judging_team.product_judge, @judging_team.concept_judge].compact.uniq
  end

  def create
    @judging_team = JudgingTeam.new(judging_team_params)
    authorize @judging_team
    if @judging_team.save
      redirect_to edit_admin_judging_team_path(@judging_team), notice: "Judging team created"
    else
      render :new, alert: "Failed to create judging team: " + @judging_team.errors.full_messages.join(", ")
    end
  end

  def edit
    @judging_team = JudgingTeam.find(params[:id]).decorate
    authorize @judging_team

    @judges = User.unassigned_judges + [@judging_team.technical_judge, @judging_team.product_judge, @judging_team.concept_judge].compact.uniq
  end

  def update
    @judging_team = JudgingTeam.find(params[:id])
    authorize @judging_team

    @judging_team.update(judging_team_params)
    redirect_to edit_admin_judging_team_path(@judging_team), notice: "Judging team updated"
  end

  private
  def judging_team_params
    params.require(:judging_team).permit(:concept_judge_id, :product_judge_id, :technical_judge_id, :track)
  end
end
