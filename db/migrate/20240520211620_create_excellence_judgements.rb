class CreateExcellenceJudgements < ActiveRecord::Migration[7.1]
  def change
    create_table :excellence_judgements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :submission, null: false, foreign_key: true

      t.index %i[user_id submission_id], unique: true

      t.float :score, null: false

      t.timestamps
    end
  end
end
