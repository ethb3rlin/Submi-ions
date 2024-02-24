# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  email         :string
#  github_handle :string
#  name          :string
#  super_admin   :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class User < ApplicationRecord
    has_many :ethereum_addresses
end
