class HackingTeamPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    user.present? && !user.hacking_team.present?
  end

  def create?
    new?
  end

  def show?
    true
  end

  def list_members?
    user.present? && (user.organizer? || user.hacking_team == record)
  end

  def leave?
    user.present? && user.hacking_team == record
  end

  def apply?
    user.present? && user.hacker? && (!user.hacking_team.present? || user.hacking_team == record)
  end

  def accept?
    user.present? && (user.organizer? || user.hacking_team == record)
  end

  def reject?
    accept?
  end

  def unreject?
    accept?
  end
end
