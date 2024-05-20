class CreateExcellenceTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :excellence_teams do |t|
      t.enum :track, enum_type: :excellence_award_track, null: false

      t.timestamps
    end
  end
end
