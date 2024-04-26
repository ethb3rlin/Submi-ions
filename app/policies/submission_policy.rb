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
    user.present? && user.organizer? # TODO: Do we even want to destroy (and not just soft-delete) submissions?
  end
end
