# == Schema Information
#
# Table name: settings
#
#  key        :string           not null, primary key
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Setting < ApplicationRecord
  def self.[](key)
    Setting.find_or_create_by(key: key)
  end

  def self.load_with_default(key, default)
    Setting.create_with(value: default).find_or_create_by(key: key)
  end

  def self.[]=(key, value)
    Setting.upsert({ key: key, value: value }, unique_by: :key)
  end

  HACKATHON_STAGES = %i[registration hacking judging finalizing]

  def self.hackathon_stage
    self.load_with_default(:hackathon_stage, HACKATHON_STAGES.first).value.to_sym
  end

  def self.hackathon_stage=(stage)
    stage = stage.to_sym
    raise ArgumentError, "Invalid hackathon stage: #{stage}" unless HACKATHON_STAGES.include?(stage)
    self[:hackathon_stage] = stage
  end
end
