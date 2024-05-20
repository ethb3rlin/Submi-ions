# == Schema Information
#
# Table name: submissions
#
#  id                     :bigint           not null, primary key
#  description            :text
#  excellence_award_track :enum
#  pitchdeck_url          :string
#  repo_url               :text
#  title                  :text
#  track                  :enum             default("infra"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  hacking_team_id        :bigint
#
# Indexes
#
#  index_submissions_on_excellence_award_track  (excellence_award_track)
#  index_submissions_on_hacking_team_id         (hacking_team_id)
#  index_submissions_on_track                   (track)
#
# Foreign Keys
#
#  fk_rails_...  (hacking_team_id => hacking_teams.id)
#

class Submission < ApplicationRecord
  has_one :judgement, -> { with_no_show }

  belongs_to :hacking_team

  has_many :comments, class_name: "SubmissionComment", dependent: :destroy

  enum :track, {transact: "transact", infra: "infra", tooling: "tooling", social: "social"}
  validates :track, presence: true
  validates :track, inclusion: { in: tracks.keys }

  enum :excellence_award_track, {smart_contracts: "smart_contracts", ux: "ux", crypto: "crypto"}
  validates :excellence_award_track, inclusion: { in: excellence_award_tracks.keys }, allow_nil: true

  scope :unassigned, -> { Submission.left_outer_joins(:judgement).where(judgements: { id: nil }) }

  scope :order_by_total_score, -> {
    joins(:judgement).joins("LEFT JOIN votes AS technical_votes ON technical_votes.id = judgements.technical_vote_id")
      .joins("LEFT JOIN votes AS product_votes ON product_votes.id = judgements.product_vote_id")
      .joins("LEFT JOIN votes AS concept_votes ON concept_votes.id = judgements.concept_vote_id")
      .select("submissions.*, (COALESCE(technical_votes.mark, 0) + COALESCE(product_votes.mark, 0) + COALESCE(concept_votes.mark, 0)) AS total_mark").order("total_mark DESC")
    }

  HUMAN_READABLE_TRACKS = {
    transact: "Freedom to Transact",
    infra: "Infrastructure",
    tooling: "Defensive Tooling",
    social: "Social Tech"
  }.with_indifferent_access

  HUMAN_READABLE_EXCELLENCE_TRACKS = {
    smart_contracts: "Smart Contracts",
    ux: "User Experience",
    crypto: "Cryptography"
  }

  TRACK_ICONS = {
    transact: "arrow-right-left",
    infra: "podcast",
    tooling: "pocket-knife",
    social: "hand-heart"
  }.with_indifferent_access

  after_initialize :set_default_description, unless: :persisted?
  after_create_commit :broadcast

  def self.distribute_unassigned!
    Judgement.suppressing_turbo_broadcasts do
      Judgement.transaction do
        HUMAN_READABLE_TRACKS.keys.each do |track|
          # Shuffle the judging teams, so on subsequent runs the team #1 won't get more submissions on average
          teams = JudgingTeam.where(track: track).shuffle.cycle
          Submission.unassigned.where(track: track).in_batches.each_record do |submission|
            Judgement.create!(judging_team: teams.next, submission: submission)
          end
        end
      end
    end
  end

  private
  def broadcast
    broadcast_append_to 'submissions', partial: 'submissions/tr', locals: { submission: self }
  end

  def set_default_description
    self.description ||= "### The problem [PROJECT NAME] solves\n\n### Challenges you ran into\n\n### Technology used"
  end
end
