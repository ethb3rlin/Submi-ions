# == Schema Information
#
# Table name: join_applications
#
#  id              :bigint           not null, primary key
#  decided_at      :datetime
#  state           :enum             default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  decided_by_id   :bigint
#  hacking_team_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_join_applications_on_decided_by_id                (decided_by_id)
#  index_join_applications_on_hacking_team_id              (hacking_team_id)
#  index_join_applications_on_state                        (state)
#  index_join_applications_on_user_id                      (user_id)
#  index_join_applications_on_user_id_and_hacking_team_id  (user_id,hacking_team_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (decided_by_id => users.id)
#  fk_rails_...  (hacking_team_id => hacking_teams.id)
#  fk_rails_...  (user_id => users.id)
#
class JoinApplication < ApplicationRecord
  belongs_to :user
  belongs_to :decided_by, class_name: 'User', foreign_key: 'decided_by_id', optional: true
  belongs_to :hacking_team

  enum :state, { pending: 'pending', approved: 'approved', declined: 'declined' }
  validates :state, presence: true

  def accept!(decided_by)
    self.transaction do
      self.update(decided_by_id: decided_by.id, state: :approved, decided_at: Time.current)
    end
  end

  def decline!(decided_by)
    self.transaction do
      self.update(decided_by_id: decided_by.id, state: :declined, decided_at: Time.current)
    end
  end
end
