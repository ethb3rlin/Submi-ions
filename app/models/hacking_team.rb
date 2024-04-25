class HackingTeam < ApplicationRecord
  has_many :hackers, inverse_of: :hacking_team
  has_many :submissions
end
