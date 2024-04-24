class JudgingTeamPolicy < ApplicationPolicy
  def index?
    user.organizer?
  end

  def new?
    user.organizer?
  end

  def create?
    user.organizer?
  end

  def show?
    user.organizer?
  end

  def edit?
    user.organizer?
  end

  def update?
    user.organizer?
  end
end
