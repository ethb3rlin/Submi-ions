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
end
