class AddExcellenceAwardsEnum < ActiveRecord::Migration[7.1]
  def change
    create_enum :excellence_award_track, %w[smart_contracts ux crypto]

    add_column :submissions, :excellence_award_track, :excellence_award_track, default: nil
    add_index :submissions, :excellence_award_track
  end
end
