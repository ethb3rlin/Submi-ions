class CreateSubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :submissions do |t|
      t.text :title
      t.text :description
      t.text :url

      t.timestamps
    end
  end
end
