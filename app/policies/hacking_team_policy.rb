class HackingTeamPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def new?
    user.present? && !user.hacking_team.present?
  end

  def create?
    new?
  end
end
