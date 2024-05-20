class ExcellenceTeamMembershipPolicy < ApplicationPolicy
  def add_user?
    user&.organizer?
  end

  def remove_user?
    user&.organizer?
  end
end
