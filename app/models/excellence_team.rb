# == Schema Information
#
# Table name: excellence_teams
#
#  id         :bigint           not null, primary key
#  track      :enum             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_excellence_teams_on_track  (track) UNIQUE
#
class ExcellenceTeam < ApplicationRecord
  has_many :excellence_team_memberships, dependent: :destroy
  has_many :users, through: :excellence_team_memberships

  has_many :excellence_judgements, through: :users

  enum :track, { smart_contracts: 'smart_contracts', ux: 'ux', social_impact: 'social_impact' }
  validates :track, presence: true, inclusion: { in: tracks.keys }
end
