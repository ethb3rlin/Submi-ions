class SubmissionCommentPolicy < ApplicationPolicy
  def show?
    user.present? && ( user.judge? || user.organizer? )
  end

  def create?
    show?
  end
end
