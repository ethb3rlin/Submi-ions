class ChangeSuperAdminsFlagToType < ActiveRecord::Migration[7.1]
  def change
    create_enum :user_type, %w[Hacker Judge Organizer]

    change_table :users do |t|
      t.remove :super_admin
      t.enum :type, enum_type: :user_type, default: 'Hacker', null: false
    end

    add_index :users, :type
  end
end
