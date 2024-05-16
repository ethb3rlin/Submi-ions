class RemoveCurrentJudgementFromJudgingTeam < ActiveRecord::Migration[7.1]
  def change
    remove_reference :judging_teams, :current_judgement, foreign_key: { to_table: :judgements }
  end
end
