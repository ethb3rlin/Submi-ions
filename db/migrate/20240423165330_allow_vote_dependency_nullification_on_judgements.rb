class AllowVoteDependencyNullificationOnJudgements < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :judgements, :votes, column: :technical_vote_id
    remove_foreign_key :judgements, :votes, column: :product_vote_id
    remove_foreign_key :judgements, :votes, column: :concept_vote_id

    add_foreign_key :judgements, :votes, column: :technical_vote_id, on_delete: :nullify
    add_foreign_key :judgements, :votes, column: :product_vote_id, on_delete: :nullify
    add_foreign_key :judgements, :votes, column: :concept_vote_id, on_delete: :nullify

    remove_foreign_key :judging_teams, :judgements, column: :current_judgement_id
    add_foreign_key :judging_teams, :judgements, column: :current_judgement_id, on_delete: :nullify
  end
end
