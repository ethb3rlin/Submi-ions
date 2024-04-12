class AddKindToUsers < ActiveRecord::Migration[7.1]
  def change
    create_enum :user_kind, %w[hacker judge organizer]

    change_table :users do |t|
      t.enum :kind, enum_type: :user_kind, default: 'hacker', null: false
    end

    add_index :users, :kind
  end
end
