# == Schema Information
#
# Table name: judging_teams
#
#  id                 :bigint           not null, primary key
#  location           :string
#  track              :enum             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  concept_judge_id   :bigint
#  product_judge_id   :bigint
#  technical_judge_id :bigint
#
# Indexes
#
#  index_judging_teams_on_concept_judge_id    (concept_judge_id)
#  index_judging_teams_on_product_judge_id    (product_judge_id)
#  index_judging_teams_on_technical_judge_id  (technical_judge_id)
#
# Foreign Keys
#
#  fk_rails_...  (concept_judge_id => users.id)
#  fk_rails_...  (product_judge_id => users.id)
#  fk_rails_...  (technical_judge_id => users.id)
#

require 'csv'

class JudgingTeam < ApplicationRecord
  belongs_to :technical_judge, class_name: "User", optional: true
  belongs_to :product_judge, class_name: "User", optional: true
  belongs_to :concept_judge, class_name: "User", optional: true

  has_many :judgements

  enum :track, {transact: "transact", infra: "infra", tooling: "tooling", social: "social"}

  validates :track, presence: true
  validates :track, inclusion: { in: tracks.keys }

  def to_csv
    attributes = %w{project scheduled_at team_name repository technical_judge product_judge concept_judge}

    CSV.generate(headers: true) do |csv|
      csv << attributes
      csv << [nil, nil, nil, nil, technical_judge.name, product_judge.name, concept_judge.name]

      judgements.order(:created_at).find_each do |judgement|
        csv << [
          judgement.submission.title,
          judgement.time,
          judgement.submission.hacking_team.name,
          judgement.submission.repo_url,
          judgement.technical_vote&.completed ? judgement.technical_vote.padded_mark : nil,
          judgement.product_vote&.completed ? judgement.product_vote.padded_mark : nil,
          judgement.concept_vote&.completed ? judgement.concept_vote.padded_mark : nil
        ]
      end
    end
  end

  def to_s
    Submission::HUMAN_READABLE_TRACKS[track] + ' #' + sequence_number.to_s
  end

  def current_judgement
    judgements.incomplete.order(:time).first
  end

  def next_judgement
    judgements.incomplete.order(:time).second
  end

  def last_judgement
    judgements.completed.order(:updated_at).last
  end

  private
  def sequence_number
    JudgingTeam.where(track: track).order(:id).pluck(:id).index(id) + 1
  end
end
