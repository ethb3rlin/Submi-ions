# == Schema Information
#
# Table name: users
#
#  id             :bigint           not null, primary key
#  approved_at    :datetime
#  email          :string
#  github_handle  :string
#  kind           :enum             default("hacker"), not null
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  approved_by_id :bigint
#
# Indexes
#
#  index_users_on_approved_by_id  (approved_by_id)
#  index_users_on_kind            (kind)
#
# Foreign Keys
#
#  fk_rails_...  (approved_by_id => users.id)
#
class User < ApplicationRecord
  has_many :ethereum_addresses, dependent: :destroy

  enum :kind, { hacker: 'hacker', judge: 'judge', organizer: 'organizer' }
  validates :kind, presence: true
  validates :kind, inclusion: { in: kinds.keys }

  has_one :technical_judging_team, class_name: 'JudgingTeam', foreign_key: 'technical_judge_id'
  has_one :product_judging_team, class_name: 'JudgingTeam', foreign_key: 'product_judge_id'
  has_one :concept_judging_team, class_name: 'JudgingTeam', foreign_key: 'concept_judge_id'

  has_one :excellence_team_membership
  has_one :excellence_team, through: :excellence_team_membership

  has_many :join_applications, inverse_of: :user
  has_many :accepted_join_applications, -> { where(state: :approved) }, class_name: 'JoinApplication'

  has_many :hacking_teams, through: :accepted_join_applications
  # User shouldn't belong to a hacking team unless their kind is :hacker
  validates :hacking_teams, absence: true, unless: -> { hacker? }

  belongs_to :approved_by, class_name: 'User', optional: true

  # Scope to users which have `approved_at` set by default
  default_scope { where.not(approved_at: nil) }
  scope :approval_pending, -> { unscope(where: :approved_at).where(approved_at: nil) }

  after_update_commit :refresh_user_page, if: -> { saved_change_to_approved_at? }

  def approved?
    approved_at.present?
  end

  def approve_as!(user)
    update!(approved_at: DateTime.now, approved_by: user)
  end

  def judging_team
    JudgingTeam.where('technical_judge_id = :id OR product_judge_id = :id OR concept_judge_id = :id', id: self.id).first
  end

  def self.unassigned_judges
    User.judge.where.not(id: JudgingTeam.pluck(:technical_judge_id).compact + JudgingTeam.pluck(:product_judge_id).compact +
        JudgingTeam.pluck(:concept_judge_id).compact + ExcellenceTeamMembership.pluck(:user_id).compact ).order(:name)
  end

  private
  def refresh_user_page
    broadcast_refresh
  end
end
