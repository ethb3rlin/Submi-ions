class RemoveHackingTeamIdFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_reference :users, :hacking_team
  end
end
