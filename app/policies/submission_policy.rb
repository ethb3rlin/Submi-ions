class SubmissionPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def new?
    user.present?
  end

  def show?
    true
  end

  def update?
    user.present? && (record.user == user || user.super_admin?)
  end

  def destroy?
    user.present? && (record.user == user || user.super_admin?)
  end
end
