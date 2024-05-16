class JudgementCommentPolicy < ApplicationPolicy
  def show?
    user.present? && ( user.judge? || user.organizer? )
  end

  def create?
    user.present? && user.judge? && record.judgement.judging_team == user.judging_team && record.user == user
  end
end
