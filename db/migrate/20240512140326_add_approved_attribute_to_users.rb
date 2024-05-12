class AddApprovedAttributeToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.datetime :approved_at, null: true, default: nil
      t.references :approved_by, foreign_key: { to_table: :users }, null: true, default: nil
    end
  end
end
