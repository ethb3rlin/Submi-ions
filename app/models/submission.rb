# == Schema Information
#
# Table name: submissions
#
#  id          :bigint           not null, primary key
#  description :text
#  title       :text
#  url         :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Submission < ApplicationRecord
  has_one :judgement

  def github_repo?
    url.present? && url.include?('github.com')
  end

  def user
    nil
  end
end
