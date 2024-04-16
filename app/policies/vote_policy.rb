class VotePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def new?
    user.present?
  end

  def show?
    true
  end

  def complete?
    user.present? && record.user == user
  end

  def update?
    user.present? && (record.user == user || user.organizer?)
  end

  def destroy?
    user.present? && (record.user == user || user.organizer?)
  end
end
