class CreateTicketInvalidations < ActiveRecord::Migration[7.1]
  def change
    create_table :ticket_invalidations, id: false, primary_key: :ticket_id do |t|
      t.uuid :ticket_id, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps

      t.index :ticket_id, unique: true
    end
  end
end
