class ExcellenceJudgementPolicy < ApplicationPolicy
  def update?
    user&.judge? && record.submission.excellence_award_track == user.excellence_team.track && Setting.hackathon_stage == :judging
  end
end
