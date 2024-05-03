# == Schema Information
#
# Table name: judging_teams
#
#  id                   :bigint           not null, primary key
#  track                :enum             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  concept_judge_id     :bigint
#  current_judgement_id :bigint
#  product_judge_id     :bigint
#  technical_judge_id   :bigint
#
# Indexes
#
#  index_judging_teams_on_concept_judge_id      (concept_judge_id)
#  index_judging_teams_on_current_judgement_id  (current_judgement_id)
#  index_judging_teams_on_product_judge_id      (product_judge_id)
#  index_judging_teams_on_technical_judge_id    (technical_judge_id)
#
# Foreign Keys
#
#  fk_rails_...  (concept_judge_id => users.id)
#  fk_rails_...  (current_judgement_id => judgements.id) ON DELETE => nullify
#  fk_rails_...  (product_judge_id => users.id)
#  fk_rails_...  (technical_judge_id => users.id)
#

require 'csv'

class JudgingTeam < ApplicationRecord
  belongs_to :technical_judge, class_name: "User", optional: true
  belongs_to :product_judge, class_name: "User", optional: true
  belongs_to :concept_judge, class_name: "User", optional: true

  has_many :judgements

  belongs_to :current_judgement, class_name: "Judgement", optional: true

  enum :track, {transact: "transact", infra: "infra", tooling: "tooling", social: "social"}

  validates :track, presence: true
  validates :track, inclusion: { in: tracks.keys }

  def pending_submissions
    # TODO filter this by track (and account for multi-teams) when Submission will have a track column
    Submission.left_outer_joins(:judgement).where(judgements: { id: nil })
  end

  def to_csv
    attributes = %w{team_name project repository technical_judge product_judge concept_judge}

    CSV.generate(headers: true) do |csv|
      csv << attributes
      csv << [nil, nil, nil, technical_judge.name, product_judge.name, concept_judge.name]

      judgements.order(:created_at).find_each do |judgement|
        csv << [
          nil, # TODO judgement.submission.team_name,
          judgement.submission.title,
          judgement.submission.url,
          judgement.technical_vote.completed ? judgement.technical_vote.padded_mark : nil,
          judgement.product_vote.completed ? judgement.product_vote.padded_mark : nil,
          judgement.concept_vote.completed ? judgement.concept_vote.padded_mark : nil
        ]
      end
    end
  end

  def to_s
    Submission::HUMAN_READABLE_TRACKS[track] + ' #' + sequence_number.to_s
  end

  private
  def sequence_number
    JudgingTeam.where(track: track).order(:id).pluck(:id).index(id) + 1
  end
end
