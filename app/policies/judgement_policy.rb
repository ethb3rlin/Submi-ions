class JudgementPolicy < ApplicationPolicy
  def index?
    user.judge? || user.organizer?
  end

  def create?
    user.judge?
  end

  def edit?
    user.judge? && record.judging_team == user.judging_team
  end
end
