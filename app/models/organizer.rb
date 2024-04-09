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
class Organizer < User
end
