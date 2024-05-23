class SubmissionPolicy < ApplicationPolicy
  def index?
    true
  end

  def results?
    return true if Setting.hackathon_stage == :published
    (user&.organizer? || user&.judge?) && Setting.hackathon_stage == :finalizing
  end

  def create?
    user.present? && user.approved? && ((user.hacker? && Setting.hackathon_stage == :hacking) || user.organizer?)
  end

  def new?
    create?
  end

  def show?
    return true unless record.draft # Everyone can see non-draft submissions
    return false unless user.present? # No one can see draft submissions if they're not logged in
    return true if user.organizer? # Organizers can see all draft submissions
    return true if user.approved? && user.hacking_teams.include?(record.hacking_team) # Hackers can see their own draft submissions
    false
  end

  def publish?
    return false unless user.present?
    return true if user.organizer?
    user.hacking_teams.include?(record.hacking_team) && Setting.hackathon_stage == :hacking
  end

  def draft?
    publish?
  end

  def update?
    user.present? && user.approved? && ((user.hacking_teams.include?(record.hacking_team) && Setting.hackathon_stage == :hacking) || user.organizer?)
  end

  def destroy?
    user.present? && user.organizer? # TODO: Do we even want to destroy (and not just soft-delete) submissions?
  end
end
