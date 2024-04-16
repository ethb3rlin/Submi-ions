class UserPolicy < ApplicationPolicy
  def index?
    user.organizer?
  end

  def new?
    user.organizer?
  end

  def create?
    user.organizer?
  end

  def edit?
    user.organizer? || user == record
  end

  def update?
    user.organizer? || user == record
  end

  def destroy?
    user.organizer?
  end
end
