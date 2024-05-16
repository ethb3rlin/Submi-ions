class CreateJudgementComments < ActiveRecord::Migration[7.1]
  def change
    create_table :judgement_comments do |t|
      t.references :judgement, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :text

      t.timestamps
    end
  end
end
