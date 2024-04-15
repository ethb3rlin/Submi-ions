class EthereumAddressPolicy < ApplicationPolicy
  def create?
    user.organizer?
  end

  def destroy?
    user.organizer?
  end
end
