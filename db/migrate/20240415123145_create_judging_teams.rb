class CreateJudgingTeams < ActiveRecord::Migration[7.1]
  def change
    create_enum :judging_track, %w[transact infra tooling social]

    create_table :judging_teams do |t|
      t.enum :track, enum_type: :judging_track, null: false

      # We can only reference Users who have `kind` set to `judge`, for all three judge types (technical, product, concept)
      t.references :technical_judge, foreign_key: { to_table: :users, where: "kind = 'judge'" }
      t.references :product_judge, foreign_key: { to_table: :users, where: "kind = 'judge'" }
      t.references :concept_judge, foreign_key: { to_table: :users, where: "kind = 'judge'" }

      t.timestamps
    end
  end
end
