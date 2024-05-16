class Admin::AdminController < ApplicationController
  def index
    authorize :admin, :index?, policy_class: AdminPolicy

    # List judging teams which have incomplete judgements
    @teams_still_judging = JudgingTeam.find(Judgement.incomplete.distinct.pluck(:judging_team_id))
  end

  def settings
    authorize :admin, :settings?, policy_class: AdminPolicy

    @job_count = Que.job_stats.find { |job| job[:job_class] == 'GenerateRandomTeamJob' }&.fetch(:count)
  end

  def update_start_time
    authorize :admin, :update_start_time?, policy_class: AdminPolicy
    Setting.judging_start_time = params[:judging_start_time]
    redirect_to admin_settings_path
  end

  def update_hackathon_stage
    authorize :admin, :update_hackathon_stage?, policy_class: AdminPolicy
    Setting.hackathon_stage = params[:hackathon_stage]
    redirect_to admin_root_path
  end

  def create_judging_break
    authorize :admin, :manage_judging_breaks?, policy_class: AdminPolicy
  end

  def update_judging_break
    authorize :admin, :manage_judging_breaks?, policy_class: AdminPolicy
  end

  def destroy_judging_break
    authorize :admin, :manage_judging_breaks?, policy_class: AdminPolicy
  end

  def reschedule
    authorize :admin, :reschedule?, policy_class: AdminPolicy

    if params[:force] == 'true'
      Judgement.empty.delete_all
    end

    Submission.distribute_unassigned!
    Judgement.schedule_missing!
    redirect_to admin_submissions_path
  end

  def generate_fake_data
    authorize :admin, :generate_fake_data?, policy_class: AdminPolicy
    amount = params[:amount].to_i
    Que.bulk_enqueue do
      amount.times do
        GenerateRandomTeamJob.enqueue
      end
    end
    redirect_to admin_settings_path, notice: "Enqueued #{amount} jobs"
  end

  def wipe_all_data
    authorize :admin, :wipe_all_data?, policy_class: AdminPolicy

    raise 'Confirmation value mismatch' unless params[:confirmation]=='RESET ETHBERLIN04'

    Setting.transaction do
      Setting.delete_all

      Vote.delete_all
      Judgement.delete_all
      Submission.delete_all

      JudgingTeam.delete_all
      JudgingBreak.delete_all

      JoinApplication.delete_all
      HackingTeam.delete_all

      TicketInvalidation.delete_all

      # Only delete Ethereum addresses which don't belong to users with role 'organizer'
      EthereumAddress.where.not(user: User.unscoped.where(kind: :organizer)).delete_all

      User.unscoped.where.not(kind: :organizer).delete_all
    end

    redirect_to admin_root_path, notice: 'All data has been wiped.'
  end
end
