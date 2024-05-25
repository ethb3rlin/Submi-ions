class RenameCryptographyIntoSocialImpactAwardTrack < ActiveRecord::Migration[7.1]
  def change
    rename_enum_value :excellence_award_track, from: 'crypto', to: 'social_impact'
  end
end
