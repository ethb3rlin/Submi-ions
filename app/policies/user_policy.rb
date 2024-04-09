class UserPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def edit?
    user.super_admin?
  end

  def update?
    user.super_admin?
  end
end

class HackerPolicy < UserPolicy
end

class JudgePolicy < UserPolicy
end

class OrganizerPolicy < UserPolicy
end
