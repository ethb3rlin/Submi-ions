class AddCompletedToVote < ActiveRecord::Migration[7.1]
  def change
    add_column :votes, :completed, :boolean, default: false
  end
end
