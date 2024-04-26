class SubmissionPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    user.present? && user.hacker?
  end

  def new?
    user.present? && user.hacker?
  end

  def show?
    true
  end

  def update?
    user.present? && (record.hacking_team == user.hacking_team || user.organizer?)
  end

  def destroy?
    user.present? && (record.hacking_team == user.hacking_team || user.organizer?)
  end
end
