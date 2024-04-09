class SubmissionPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present? && user.type == 'Hacker'
  end

  def new?
    user.present? && user.type == 'Hacker'
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
