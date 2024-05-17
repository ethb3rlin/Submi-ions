class SubmissionPolicy < ApplicationPolicy
  def index?
    true
  end

  def results?
    Setting.hackathon_stage == :finalizing
  end

  def create?
    user.present? && user.approved? && ((user.hacker? && Setting.hackathon_stage == :hacking) || user.organizer?)
  end

  def new?
    create?
  end

  def show?
    true
  end

  def update?
    user.present? && user.approved? && ((user.hacking_teams.include?(record.hacking_team) && Setting.hackathon_stage == :hacking) || user.organizer?)
  end

  def destroy?
    user.present? && user.organizer? # TODO: Do we even want to destroy (and not just soft-delete) submissions?
  end
end
