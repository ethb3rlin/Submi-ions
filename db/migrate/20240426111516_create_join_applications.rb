class CreateJoinApplications < ActiveRecord::Migration[7.1]
  def change
    create_enum :join_application_state, %w[pending approved declined]

    create_table :join_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :hacking_team, null: false, foreign_key: true

      t.references :decided_by, foreign_key: {to_table: :users}
      t.datetime :decided_at

      t.enum :state, null: false, enum_type: :join_application_state, index: true, default: 'pending'

      t.timestamps
    end

    add_index :join_applications, %i[user_id hacking_team_id], unique: true
  end
end
