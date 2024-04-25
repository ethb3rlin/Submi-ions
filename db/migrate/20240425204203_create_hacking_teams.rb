class CreateHackingTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :hacking_teams do |t|
      t.string :name
      t.timestamps
    end

    change_table :users do |t|
      t.references :hacking_team, foreign_key: true
    end

    change_table :submissions do |t|
      t.references :hacking_team, foreign_key: true
    end
  end
end
