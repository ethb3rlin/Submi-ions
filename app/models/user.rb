# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  email         :string
#  github_handle :string
#  kind          :enum             default("hacker"), not null
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_users_on_kind  (kind)
#
class User < ApplicationRecord
    has_many :ethereum_addresses, dependent: :destroy

    enum :kind, { hacker: 'hacker', judge: 'judge', organizer: 'organizer' }
    validates :kind, presence: true
    validates :kind, inclusion: { in: kinds.keys }


    has_one :technical_judging_team, class_name: 'JudgingTeam', foreign_key: 'technical_judge_id'
    has_one :product_judging_team, class_name: 'JudgingTeam', foreign_key: 'product_judge_id'
    has_one :concept_judging_team, class_name: 'JudgingTeam', foreign_key: 'concept_judge_id'

    def judging_team
        JudgingTeam.where('technical_judge_id = :id OR product_judge_id = :id OR concept_judge_id = :id', id: self.id).first
    end

    def self.unassigned_judges
        User.judge.where.not(id: JudgingTeam.pluck(:technical_judge_id).compact + JudgingTeam.pluck(:product_judge_id).compact + JudgingTeam.pluck(:concept_judge_id).compact).order(:name)
    end
end
