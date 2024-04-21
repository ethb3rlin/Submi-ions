class JudgementPolicy < ApplicationPolicy
  def index?
    user.try(:judge?) || user.try(:organizer?)
  end

  def create?
    user.try :judge?
  end

  def edit?
    user.present && user.judge? && record.judging_team == user.judging_team
  end
end
