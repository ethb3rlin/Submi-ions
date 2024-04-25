class CreateHackingTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :hacking_teams do |t|
      t.string :name

      t.text :agenda

      t.timestamps
    end

    change_table :users do |t|
      t.references :hacking_team
    end
    add_foreign_key :users, :hacking_teams, column: :hacking_team_id, on_delete: :nullify

    change_table :submissions do |t|
      t.references :hacking_team, foreign_key: true
    end
  end
end
