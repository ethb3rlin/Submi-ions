# == Schema Information
#
# Table name: votes
#
#  id            :bigint           not null, primary key
#  mark          :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  submission_id :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_votes_on_submission_id  (submission_id)
#  index_votes_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (submission_id => submissions.id)
#  fk_rails_...  (user_id => users.id)
#
class Vote < ApplicationRecord
  include ActionView::RecordIdentifier # We need this for dom_id to work
  
  belongs_to :user
  belongs_to :submission

  after_create_commit :broadcast_create
  after_update_commit :broadcast_update

  def broadcast_create
    broadcast_append_to self.submission, :votes
  end
  def broadcast_update
    broadcast_replace_to self.submission, :votes
    broadcast_replace_to self.submission, :votes, target: dom_id(self, :editable), partial: "votes/editable_vote"
  end
end
