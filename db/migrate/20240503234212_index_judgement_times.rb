class IndexJudgementTimes < ActiveRecord::Migration[7.1]
  def change
    add_index :judgements, :time
  end
end
