class SubmissionPolicy < ApplicationPolicy
  def index?
    user.present?
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
    user.present? && (record.user == user || user.organizer?)
  end

  def destroy?
    user.present? && (record.user == user || user.organizer?)
  end
end
