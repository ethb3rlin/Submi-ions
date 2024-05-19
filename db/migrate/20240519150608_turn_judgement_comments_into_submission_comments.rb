class TurnJudgementCommentsIntoSubmissionComments < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        # drop all contents of :judgement_comments without interacting with the model
        execute "DELETE FROM judgement_comments"
        remove_column :judgement_comments, :judgement_id
      end

      dir.down do
        add_reference :judgement_comments, :judgement, null: false, foreign_key: true
      end
    end

    rename_table :judgement_comments, :submission_comments
    add_reference :submission_comments, :submission, null: false, foreign_key: true
  end
end
