class JudgementPolicy < ApplicationPolicy
  def index?
    user.try(:judge?) || user.try(:organizer?)
  end

  def create?
    user.try :judge?
  end

  def show?
    user.present? && ((user.judge? && record.judging_team == user.judging_team) || user.organizer?)
  end

  def complete?
    user.present? && user.judge? && record.judging_team == user.judging_team
  end
end
