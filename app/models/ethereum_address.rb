# == Schema Information
#
# Table name: ethereum_addresses
#
#  id         :bigint           not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_ethereum_addresses_on_address  (address)
#  index_ethereum_addresses_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class EthereumAddress < ApplicationRecord
  belongs_to :user
end
