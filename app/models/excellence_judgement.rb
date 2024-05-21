# == Schema Information
#
# Table name: excellence_judgements
#
#  id            :bigint           not null, primary key
#  score         :float            not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  submission_id :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_excellence_judgements_on_submission_id              (submission_id)
#  index_excellence_judgements_on_user_id                    (user_id)
#  index_excellence_judgements_on_user_id_and_submission_id  (user_id,submission_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (submission_id => submissions.id)
#  fk_rails_...  (user_id => users.id)
#
class ExcellenceJudgement < ApplicationRecord
  belongs_to :submission
  belongs_to :user

  has_one :excellence_team, through: :user

  validates :score, presence: true
  validates :score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  default_scope { joins(:user).order("users.name")}

  after_save_commit :broadcast_score

  def dom_id
    "submission_#{submission.id}_judgement_by_#{user.id}"
  end

  def padded_score
    format("%.1f", self.score)
  end

  private
  def broadcast_score
    broadcast_replace_to excellence_team, target: self.dom_id,
      html: "<td id=\"#{self.dom_id}\">#{self.padded_score}</td>"
  end
end
