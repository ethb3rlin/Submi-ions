class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings, id: false do |t|
      t.string :key, primary_key: true, null: false
      t.string :value

      t.timestamps
    end
  end
end
