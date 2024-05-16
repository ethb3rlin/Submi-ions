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
    update?
  end

  def update?
    user.present? && user.judge? && Setting.hackathon_stage == :judging && record.suitable_judge?(user)
  end

  def destroy?
    user.present? && user.organizer?
  end
end
