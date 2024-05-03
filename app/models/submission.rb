# == Schema Information
#
# Table name: submissions
#
#  id              :bigint           not null, primary key
#  description     :text
#  title           :text
#  track           :enum             default("infra"), not null
#  url             :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  hacking_team_id :bigint
#
# Indexes
#
#  index_submissions_on_hacking_team_id  (hacking_team_id)
#  index_submissions_on_track            (track)
#
# Foreign Keys
#
#  fk_rails_...  (hacking_team_id => hacking_teams.id)
#

class Submission < ApplicationRecord
  has_one :judgement

  belongs_to :hacking_team

  enum :track, {transact: "transact", infra: "infra", tooling: "tooling", social: "social"}
  validates :track, presence: true
  validates :track, inclusion: { in: tracks.keys }

  HUMAN_READABLE_TRACKS = {
    transact: "Freedom to Transact",
    infra: "Infrastructure",
    tooling: "Defensive Tooling",
    social: "Social Tech"
  }.with_indifferent_access

  TRACK_ICONS = {
    transact: "arrow-right-left",
    infra: "podcast",
    tooling: "pocket-knife",
    social: "hand-heart"
  }.with_indifferent_access

  after_create_commit :broadcast

  private
  def broadcast
    broadcast_append_to 'submissions', partial: 'submissions/tr', locals: { submission: self }
  end
end
