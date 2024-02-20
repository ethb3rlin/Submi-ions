class CreateEthereumAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :ethereum_addresses do |t|
      t.string :address
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :ethereum_addresses, :address
  end
end
