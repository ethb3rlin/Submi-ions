class AddDraftToSubmission < ActiveRecord::Migration[7.1]
  def change
    add_column :submissions, :draft, :boolean, default: false
  end
end
