# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  email         :string
#  github_handle :string
#  kind          :enum             default(NULL), not null
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_users_on_kind  (kind)
#
class User < ApplicationRecord
    has_many :ethereum_addresses


    enum :kind, { hacker: 'hacker', judge: 'judge', organizer: 'organizer' }
end
