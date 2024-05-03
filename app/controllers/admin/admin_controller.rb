class Admin::AdminController < ApplicationController
  def index
    authorize :admin, :index?, policy_class: AdminPolicy
  end

  def settings
    authorize :admin, :settings?, policy_class: AdminPolicy
  end

  def update_start_time
    authorize :admin, :update_start_time?, policy_class: AdminPolicy
    Setting.judging_start_time = params[:judging_start_time]
    redirect_to admin_settings_path
  end

  def next_hackathon_stage
    authorize :admin, :update_hackathon_stage?, policy_class: AdminPolicy
    Setting.hackathon_stage = Setting.next_hackathon_stage
    redirect_to admin_root_path
  end

  def update_hackathon_stage
    authorize :admin, :update_hackathon_stage?, policy_class: AdminPolicy
    Setting.hackathon_stage = params[:hackathon_stage]
    redirect_to admin_settings_path
  end
end
