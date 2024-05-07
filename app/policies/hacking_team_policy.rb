class HackingTeamPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    user.present? && (user.organizer? || user.hacking_teams.count < 2)
  end

  def create?
    new?
  end

  def show?
    true
  end

  def edit?
    user.present? && (user.organizer? || user.hacking_teams.include?(record))
  end

  def update?
    edit?
  end

  def list_members?
    user.present? && (user.organizer? || user.hacking_teams.include?(record))
  end

  def leave?
    user.present? && user.hacking_teams.include?(record)
  end

  def apply?
    user.present? && user.hacker? && (!user.hacking_teams.include?(record)) && user.hacking_teams.count < 2
  end

  def accept?
    user.present? && (user.organizer? || user.hacking_teams.include?(record))
  end

  def reject?
    accept?
  end

  def unreject?
    accept?
  end

  def kick?
    accept?
  end
end
