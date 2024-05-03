class AddLocationToJudgingTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :judging_teams, :location, :string
  end
end
