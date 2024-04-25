# == Schema Information
#
# Table name: hacking_teams
#
#  id         :bigint           not null, primary key
#  agenda     :text
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class HackingTeam < ApplicationRecord
  has_many :hackers, inverse_of: :hacking_team
  has_many :submissions

  validates :name, presence: true, uniqueness: true
end
