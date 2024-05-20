# == Schema Information
#
# Table name: excellence_team_memberships
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  excellence_team_id :bigint           not null
#  user_id            :bigint           not null
#
# Indexes
#
#  idx_on_user_id_excellence_team_id_1dc1542532             (user_id,excellence_team_id) UNIQUE
#  index_excellence_team_memberships_on_excellence_team_id  (excellence_team_id)
#  index_excellence_team_memberships_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (excellence_team_id => excellence_teams.id)
#  fk_rails_...  (user_id => users.id)
#
class ExcellenceTeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :excellence_team
end
