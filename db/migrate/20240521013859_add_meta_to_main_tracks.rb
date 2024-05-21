class AddMetaToMainTracks < ActiveRecord::Migration[7.1]
  def up
    add_enum_value :judging_track, 'meta'
  end
end
