class AddNoShowFlagToJudgement < ActiveRecord::Migration[7.1]
  def change
    add_column :judgements, :no_show, :boolean, default: false, null: false
  end
end
