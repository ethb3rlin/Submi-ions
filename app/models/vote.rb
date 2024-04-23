# == Schema Information
#
# Table name: votes
#
#  id         :bigint           not null, primary key
#  completed  :boolean          default(FALSE)
#  mark       :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_votes_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Vote < ApplicationRecord
  include ActionView::RecordIdentifier # We need this for dom_id to work

  belongs_to :user

  has_one :technical_vote_judgement, class_name: "Judgement", foreign_key: "technical_vote_id", dependent: :destroy
  has_one :product_vote_judgement, class_name: "Judgement", foreign_key: "product_vote_id", dependent: :destroy
  has_one :concept_vote_judgement, class_name: "Judgement", foreign_key: "concept_vote_id", dependent: :destroy

  validates :mark, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  after_update_commit :broadcast_update
  after_save_commit :check_judgement_completion

  def judgement
    technical_vote_judgement || product_vote_judgement || concept_vote_judgement
  end

  def padded_mark
    format("%.1f", self.mark)
  end

  private
  def broadcast_update
    association = if technical_vote_judgement.present?
      {judgement: technical_vote_judgement, kind: :technical}
    elsif product_vote_judgement.present?
      {judgement: product_vote_judgement, kind: :product}
    elsif concept_vote_judgement.present?
      {judgement: concept_vote_judgement, kind: :concept}
    end

    if association[:judgement].completed?
      broadcast_append_to association[:judgement], :votes, html: '<script>if (window.location.pathname.match(/^\/judgements\/\d+\/edit$/) && CURRENT_USER_ROLE==="judge") { window.location = "/judgements"; }</script>'.html_safe
    end

    broadcast_replace_to association[:judgement], :votes, locals: {kind: association[:kind]}
  end

  def check_judgement_completion
    judgement.judging_team.update!(current_judgement: nil) if judgement.try :completed?
  end

end
