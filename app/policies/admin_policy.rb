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

  def next_hackathon_stage?
    user.try :organizer?
  end
end
