class ExcellenceJudgementPolicy < ApplicationPolicy
  def index?
    return false unless user.present?
    return true if user.organizer?

    user.judge? && Setting.hackathon_stage.in?(%i[judging finalizing published])
  end

  def update?
    user&.judge? && record.submission.excellence_award_track == user.excellence_team.track && Setting.hackathon_stage == :judging
  end
end
