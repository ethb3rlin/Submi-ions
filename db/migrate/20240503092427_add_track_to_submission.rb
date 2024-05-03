class AddTrackToSubmission < ActiveRecord::Migration[7.1]
  def change
    change_table :submissions do |t|
      # We only need default option here to migrate existing data in staging deployments
      t.enum :track, enum_type: :judging_track, null: false, default: "infra"
    end

    add_index :submissions, :track
  end
end
