class JudgingBreakPolicy < ApplicationPolicy
  def create?
    user.try(:organizer?)
  end
  def update?
    user.try(:organizer?)
  end
  def destroy?
    user.try(:organizer?)
  end
end
