class JudgingTeamPolicy < ApplicationPolicy
  def index?
    user.organizer?
  end

  def edit?
    user.organizer?
  end

  def update?
    user.organizer?
  end
end
