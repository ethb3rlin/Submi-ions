class UsersController < ApplicationController
  skip_after_action :verify_authorized, only: [:home]

  def home
    return render inline: '', layout: 'error', status: 500 if flash[:from_exception_handler]

    return redirect_to submissions_path unless current_user
    return redirect_to edit_user_path(current_user) unless current_user.approved?
    return redirect_to results_submissions_path if policy(Submission).results?
    return redirect_to admin_root_path if current_user.organizer?
    if current_user.judge?
      if Setting.hackathon_stage == :judging
        if current_user.judging_team.present?
          return redirect_to judgements_path
        elsif current_user.excellence_team.present?
          return redirect_to excellence_judgements_path
        else
          return redirect_to submissions_path
        end
      else
        return redirect_to submissions_path
      end
    end

    @teams = current_user.hacking_teams
    @current_team = HackingTeam.find_by(id: params[:team_id]) || @teams.first
    @submissions = @current_team.submissions.with_drafts.order(created_at: :desc) rescue []
  end

  def edit
    @user = User.unscoped.find(params[:id])
    authorize @user

    @ticket_invalidation = TicketInvalidation.find_by(user: @user)
  end

  def verify_zupass_credentials
    @user = User.unscoped.find(params[:user_id])
    authorize @user

    background_checker_url = ENV.fetch('ZUPASS_CHECKER_URL', 'localhost:8000')
    # Adding http: if there is no protocol in the URL
    background_checker_url = 'http://' + background_checker_url unless background_checker_url.match?(/https?:\/\//)

    proof = JSON.parse(params[:proof])
    pcd = JSON.parse(proof['pcd'])

    raise 'Wrong proof type' unless proof['type'] == "zk-eddsa-event-ticket-pcd"

    watermark = pcd['claim']['watermark']
    raise 'Watermark mismatch for user #{@user.id}' unless watermark == helpers.watermark_digest(@user)

    ticket_id = pcd['claim']['partialTicket']['ticketId']
    raise "Ticket #{ticket_id} has already been used" if TicketInvalidation.exists?(ticket_id: ticket_id)

    raise "Ticket #{ticket_id} has been revoked" unless pcd['claim']['partialTicket']['isRevoked'] == false

    product_id = pcd['claim']['partialTicket']['productId']
    user_role = case product_id
      when "caa5cb88-19cc-4ee2-bf3d-6d379ce5e611" #productName: "Team"
        :organizer
      when "beb248b4-9ef8-422f-b475-e94234721dc1" #productName: "Reviewer"
        :judge
      when "e6a44839-76f5-4a47-8b3b-bb95ea6fc3cc", "a28bfaa9-2843-48b9-9200-f12dae4a483f" # "Hacker", "Reviewer"
        :hacker
      else
        raise "Unknown product ID #{product_id} in ZuPass claim"
      end

    validation_response = HTTParty.post(background_checker_url, body: pcd.to_json, headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'})

    if validation_response.code == 200
      logger.info "ZuPass validation successful for user #{@user.id}"
      User.transaction do
        @user.update!(approved_at: DateTime.now, kind: user_role)
        TicketInvalidation.create!(ticket_id: ticket_id, user: @user)
      end

      ## This is going to be rendered in a popup, so everything we need is a 200 response which will show huge OK and then close itself in 2 seconds
      render inline: '<h1>OK</h1><script>setTimeout(() => window.close(), 2000)</script>'
    else
      logger.warn "ZuPass validation failed for user #{@user.id}"
      logger.warn validation_response

      head :unprocessable_entity
    end
  end

  def update
    @user = User.unscoped.find(params[:id])
    authorize @user

    if @user.update(user_params)
      redirect_to root_path
    else
      render :edit, alert: 'There was an error updating your profile: ' + @user.errors.full_messages.join(', ')
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
