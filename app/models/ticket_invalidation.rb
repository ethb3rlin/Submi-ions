# == Schema Information
#
# Table name: ticket_invalidations
#
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ticket_id  :uuid             not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_ticket_invalidations_on_ticket_id  (ticket_id) UNIQUE
#  index_ticket_invalidations_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class TicketInvalidation < ApplicationRecord
  self.primary_key = 'ticket_id'

  belongs_to :user
end
