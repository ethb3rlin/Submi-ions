class HackingTeamPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    user.present? && user.approved? && (user.organizer? || user.hacking_teams.count < 2)
  end

  def create?
    new?
  end

  def show?
    true
  end

  def edit?
    user.present? && user.approved? && (user.organizer? || user.hacking_teams.include?(record))
  end

  def update?
    edit?
  end

  def list_members?
    edit?
  end

  def list_invitations?
    edit?
  end

  def leave?
    user.present? && user.approved? && user.hacking_teams.include?(record)
  end

  def apply?
    return false unless user.present? && user.approved?
    # For hackers, only allow applying to the teams which have less than 5 members
    user.hacker? && !user.hacking_teams.include?(record) && user.hacking_teams.count < 2 && record.hackers.count < 5
  end

  def accept?
    return false unless user.present? && user.approved?
    return true if user.organizer?
    # For hackers, only allow accepting if the team has less than 5 members
    user.hacking_teams.include?(record) && record.hackers.count < 5
  end

  def admin_members?
    user.present? && user.organizer?
  end

  def force_add?
    admin_members?
  end

  def reject?
    accept?
  end

  def unreject?
    edit?
  end

  def kick?
    accept?
  end
end
