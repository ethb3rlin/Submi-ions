# == Schema Information
#
# Table name: submission_comments
#
#  id            :bigint           not null, primary key
#  text          :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  submission_id :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_submission_comments_on_submission_id  (submission_id)
#  index_submission_comments_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (submission_id => submissions.id)
#  fk_rails_...  (user_id => users.id)
#
class SubmissionComment < ApplicationRecord
  include ActionView::RecordIdentifier # We need this for dom_id to work

  belongs_to :submission, inverse_of: :comments
  belongs_to :user

  validates :text, presence: true

  after_create_commit :broadcast_new_comment

  private
  def broadcast_new_comment
    broadcast_before_to submission, :comments, target: "comment_form"
  end
end
