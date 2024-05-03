class AddTimeToJudgement < ActiveRecord::Migration[7.1]
  def change
    add_column :judgements, :time, :time
  end
end
