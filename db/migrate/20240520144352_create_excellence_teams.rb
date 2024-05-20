class CreateExcellenceTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :excellence_teams do |t|
      t.enum :track, enum_type: :excellence_award_track, null: false
      t.index :track, unique: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Submission::HUMAN_READABLE_EXCELLENCE_TRACKS.each do |track, _|
          ExcellenceTeam.create!(track: track)
        end
      end
    end
  end
end
