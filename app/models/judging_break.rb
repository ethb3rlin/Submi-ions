# == Schema Information
#
# Table name: judging_breaks
#
#  id         :bigint           not null, primary key
#  begins     :time             not null
#  ends       :time             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_judging_breaks_on_begins  (begins)
#  index_judging_breaks_on_ends    (ends)
#
class JudgingBreak < ApplicationRecord
  validates :begins, presence: true
  validates :ends, presence: true
  # When saving a record, we need to ensure that begins and ends don't overlap with other records:
  validate :no_overlapping_breaks

  private
  def no_overlapping_breaks
    if JudgingBreak.where("begins < :ends AND ends > :begins AND id <> :self_id", begins: begins, ends: ends, self_id: id).exists?
      errors.add(:begins, "can't overlap with another break")
    end
  end
end
