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
  has_many :submissions

  has_many :join_applications
  has_many :accepted_join_applications, -> { where(state: :approved) }, class_name: 'JoinApplication'
  has_many :hackers, through: :accepted_join_applications, source: :user

  validates :name, presence: true, uniqueness: true
end
