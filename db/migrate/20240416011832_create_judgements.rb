class CreateJudgements < ActiveRecord::Migration[7.1]
  def change
    create_table :judgements do |t|
      t.references :judging_team, null: false, foreign_key: true
      t.references :submission, null: false, foreign_key: true

      t.references :technical_vote, foreign_key: { to_table: :votes }
      t.references :product_vote, foreign_key: { to_table: :votes }
      t.references :concept_vote, foreign_key: { to_table: :votes }

      t.timestamps
    end

    change_table :votes do |t|
      t.remove_references :submission
    end

    change_table :judging_teams do |t|
      t.references :current_judgement, foreign_key: { to_table: :judgements }
    end
  end
end
