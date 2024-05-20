# == Schema Information
#
# Table name: excellence_teams
#
#  id         :bigint           not null, primary key
#  track      :enum             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ExcellenceTeam < ApplicationRecord
  has_many :excellence_team_memberships, dependent: :destroy
  has_many :users, through: :excellence_team_memberships

  enum :track, { smart_contracts: 'smart_contracts', ux: 'ux', crypto: 'crypto' }
  validates :track, presence: true, inclusion: { in: tracks.keys }
end
