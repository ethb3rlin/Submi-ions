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
class JudgingTeam < ApplicationRecord
  belongs_to :technical_judge, class_name: "User", optional: true
  belongs_to :product_judge, class_name: "User", optional: true
  belongs_to :concept_judge, class_name: "User", optional: true

  has_many :judgements

  belongs_to :current_judgement, class_name: "Judgement", optional: true

  enum :track, {transact: "transact", infra: "infra", tooling: "tooling", social: "social"}
  validates :track, presence: true
  validates :track, inclusion: { in: tracks.keys }
end
