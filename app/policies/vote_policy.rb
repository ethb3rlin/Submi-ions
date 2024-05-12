class VotePolicy < ApplicationPolicy
  def index?
    user.present? && (user.organizer? || user.judge?)
  end

  def create?
    user.present? && (user.organizer? || user.judge?)
  end

  def new?
    user.present? && (user.organizer? || user.judge?)
  end

  def show?
    true
  end

  def complete?
    user.present? && (user.organizer? || user.judge?) && record.user == user
  end

  def update?
    user.present? && (record.user == user || user.organizer?)
  end

  def destroy?
    user.present? && (record.user == user || user.organizer?)
  end
end
