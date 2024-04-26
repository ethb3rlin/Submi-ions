# == Schema Information
#
# Table name: submissions
#
#  id              :bigint           not null, primary key
#  description     :text
#  title           :text
#  url             :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  hacking_team_id :bigint
#
# Indexes
#
#  index_submissions_on_hacking_team_id  (hacking_team_id)
#
# Foreign Keys
#
#  fk_rails_...  (hacking_team_id => hacking_teams.id)
#

class Submission < ApplicationRecord
  has_one :judgement

  belongs_to :hacking_team

  after_create_commit :broadcast

  def github_repo?
    url.present? && url.include?('github.com')
  end

  private
  def broadcast
    broadcast_append_to 'submissions', partial: 'submissions/tr', locals: { submission: self }
  end
end
