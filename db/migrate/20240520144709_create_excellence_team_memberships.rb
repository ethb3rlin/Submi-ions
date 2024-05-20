class CreateExcellenceTeamMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :excellence_team_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :excellence_team, null: false, foreign_key: true

      t.timestamps
    end

    add_index :excellence_team_memberships, [:user_id, :excellence_team_id], unique: true
  end
end
