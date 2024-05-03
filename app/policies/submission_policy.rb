class SubmissionPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    user.present? && user.hacker? && Setting.hackathon_stage == :hacking
  end

  def new?
    create?
  end

  def show?
    true
  end

  def update?
    user.present? && (record.hacking_team == user.hacking_team || user.organizer?) && Setting.hackathon_stage == :hacking
  end

  def destroy?
    user.present? && user.organizer? # TODO: Do we even want to destroy (and not just soft-delete) submissions?
  end
end
