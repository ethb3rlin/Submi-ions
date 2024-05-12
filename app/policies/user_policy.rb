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

  def verify_zupass_credentials?
    user == record
  end

  def edit?
    user.organizer? || user == record
  end

  def update?
    user.organizer? || user == record
  end

  def manually_approve?
    user.organizer?
  end

  def unapprove?
    manually_approve?
  end

  def destroy?
    user.organizer?
  end
end
