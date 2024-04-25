class Admin::JudgingTeamsController < ApplicationController
  def index
    @judging_teams = JudgingTeam.order(:id).all
    authorize @judging_teams

    @current_team = JudgingTeam.find(params[:id]) rescue @judging_teams.first

    @judgements = @current_team&.judgements&.order(:created_at) # @current_team can be nil if there are no teams yet
  end

  def new
    @judging_team = JudgingTeam.new
    authorize @judging_team

    @judges = User.unassigned_judges + [@judging_team.technical_judge, @judging_team.product_judge, @judging_team.concept_judge].compact.uniq
  end

  def show
    @judging_team = JudgingTeam.find(params[:id])
    authorize @judging_team
    @judgements = @judging_team.judgements.order(:created_at)

    respond_to do |format|
      format.csv do
        headers['Pragma'] = 'public'
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Expires'] = "0"
        send_data @judging_team.to_csv, type: "text/csv", filename: @judging_team.decorate.track_name + " Judgements.csv"
      end
    end
  end

  def create
    @judging_team = JudgingTeam.new(judging_team_params)
    authorize @judging_team
    if @judging_team.save
      redirect_to admin_judging_teams_path, notice: "Judging team #{@judging_team.id} created"
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
    redirect_to admin_judging_teams_path, notice: "Judging team #{@judging_team.id} updated"
  end

  private
  def judging_team_params
    params.require(:judging_team).permit(:concept_judge_id, :product_judge_id, :technical_judge_id, :track)
  end
end
