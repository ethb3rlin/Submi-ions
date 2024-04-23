# == Schema Information
#
# Table name: judgements
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  concept_vote_id   :bigint
#  judging_team_id   :bigint           not null
#  product_vote_id   :bigint
#  submission_id     :bigint           not null
#  technical_vote_id :bigint
#
# Indexes
#
#  index_judgements_on_concept_vote_id    (concept_vote_id)
#  index_judgements_on_judging_team_id    (judging_team_id)
#  index_judgements_on_product_vote_id    (product_vote_id)
#  index_judgements_on_submission_id      (submission_id)
#  index_judgements_on_technical_vote_id  (technical_vote_id)
#
# Foreign Keys
#
#  fk_rails_...  (concept_vote_id => votes.id) ON DELETE => nullify
#  fk_rails_...  (judging_team_id => judging_teams.id)
#  fk_rails_...  (product_vote_id => votes.id) ON DELETE => nullify
#  fk_rails_...  (submission_id => submissions.id)
#  fk_rails_...  (technical_vote_id => votes.id) ON DELETE => nullify
#
class Judgement < ApplicationRecord
  include ActionView::RecordIdentifier # We need this for dom_id to work

  belongs_to :judging_team
  belongs_to :submission

  belongs_to :technical_vote, class_name: "Vote", dependent: :destroy
  belongs_to :product_vote, class_name: "Vote", dependent: :destroy
  belongs_to :concept_vote, class_name: "Vote", dependent: :destroy

  validates :judging_team, presence: true
  validates :submission, presence: true

  after_create_commit :broadcast_new_judgement

  def completed?
    technical_vote.completed && product_vote.completed && concept_vote.completed
  end

  private
  def broadcast_new_judgement
    broadcast_append_to judging_team, :judgements, locals: {judgement: self}, target: dom_id(judging_team, :judgements)
  end
end
