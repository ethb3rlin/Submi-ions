# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def index?
    user.try :organizer?
  end

  def settings?
    user.try :organizer?
  end

  def update_start_time?
    user.try :organizer?
  end

  def update_hackathon_stage?
    user.try :organizer?
  end

  def reschedule?
    user.try :organizer?
  end

  def generate_fake_data?
    user.try(:organizer?) && ENV['ALLOW_DANGEROUS_OPERATIONS']=='true'
  end

  def wipe_all_data?
    user.try(:organizer?) && ENV['ALLOW_DANGEROUS_OPERATIONS']=='true'
  end
end
