# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  email         :string
#  github_handle :string
#  name          :string
#  type          :enum             default("Hacker"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_users_on_type  (type)
#
class User < ApplicationRecord
    has_many :ethereum_addresses

    def super_admin?
        type == 'Organizer'
    end
end
