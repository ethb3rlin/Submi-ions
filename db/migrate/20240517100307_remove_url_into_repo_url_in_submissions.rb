class RemoveUrlIntoRepoUrlInSubmissions < ActiveRecord::Migration[7.1]
  def change
    change_table :submissions do |t|
      t.rename :url, :repo_url

      t.string :pitchdeck_url
    end
  end
end
