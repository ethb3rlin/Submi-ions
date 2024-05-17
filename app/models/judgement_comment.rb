# == Schema Information
#
# Table name: judgement_comments
#
#  id           :bigint           not null, primary key
#  text         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  judgement_id :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_judgement_comments_on_judgement_id  (judgement_id)
#  index_judgement_comments_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (judgement_id => judgements.id)
#  fk_rails_...  (user_id => users.id)
#
class JudgementComment < ApplicationRecord
  include ActionView::RecordIdentifier # We need this for dom_id to work

  belongs_to :judgement, -> { with_no_show }, inverse_of: :comments
  belongs_to :user

  validates :text, presence: true

  after_create_commit :broadcast_new_comment

  private
  def broadcast_new_comment
    broadcast_append_to judgement, :comments, target: dom_id(judgement, :comments)
  end
end
