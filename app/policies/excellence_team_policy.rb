class ExcellenceTeamPolicy < ApplicationPolicy
  def index?
    user&.organizer?
  end
end
