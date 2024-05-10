class CreateJudgingBreaks < ActiveRecord::Migration[7.1]
  def change
    create_table :judging_breaks do |t|
      t.time :begins, null: false
      t.time :ends, null: false

      t.timestamps
    end
    add_index :judging_breaks, :begins
    add_index :judging_breaks, :ends
  end
end
