# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_04_26_111516) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "join_application_state", ["pending", "approved", "declined"]
  create_enum "judging_track", ["transact", "infra", "tooling", "social"]
  create_enum "user_kind", ["hacker", "judge", "organizer"]

  create_table "ethereum_addresses", force: :cascade do |t|
    t.string "address"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_ethereum_addresses_on_address"
    t.index ["user_id"], name: "index_ethereum_addresses_on_user_id"
  end

  create_table "hacking_teams", force: :cascade do |t|
    t.string "name"
    t.text "agenda"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "join_applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "hacking_team_id", null: false
    t.bigint "decided_by_id"
    t.datetime "decided_at"
    t.enum "state", default: "pending", null: false, enum_type: "join_application_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decided_by_id"], name: "index_join_applications_on_decided_by_id"
    t.index ["hacking_team_id"], name: "index_join_applications_on_hacking_team_id"
    t.index ["state"], name: "index_join_applications_on_state"
    t.index ["user_id", "hacking_team_id"], name: "index_join_applications_on_user_id_and_hacking_team_id", unique: true
    t.index ["user_id"], name: "index_join_applications_on_user_id"
  end

  create_table "judgements", force: :cascade do |t|
    t.bigint "judging_team_id", null: false
    t.bigint "submission_id", null: false
    t.bigint "technical_vote_id"
    t.bigint "product_vote_id"
    t.bigint "concept_vote_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["concept_vote_id"], name: "index_judgements_on_concept_vote_id"
    t.index ["judging_team_id"], name: "index_judgements_on_judging_team_id"
    t.index ["product_vote_id"], name: "index_judgements_on_product_vote_id"
    t.index ["submission_id"], name: "index_judgements_on_submission_id"
    t.index ["technical_vote_id"], name: "index_judgements_on_technical_vote_id"
  end

  create_table "judging_teams", force: :cascade do |t|
    t.enum "track", null: false, enum_type: "judging_track"
    t.bigint "technical_judge_id"
    t.bigint "product_judge_id"
    t.bigint "concept_judge_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "current_judgement_id"
    t.index ["concept_judge_id"], name: "index_judging_teams_on_concept_judge_id"
    t.index ["current_judgement_id"], name: "index_judging_teams_on_current_judgement_id"
    t.index ["product_judge_id"], name: "index_judging_teams_on_product_judge_id"
    t.index ["technical_judge_id"], name: "index_judging_teams_on_technical_judge_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "hacking_team_id"
    t.index ["hacking_team_id"], name: "index_submissions_on_hacking_team_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "github_handle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "kind", default: "hacker", null: false, enum_type: "user_kind"
    t.bigint "hacking_team_id"
    t.index ["hacking_team_id"], name: "index_users_on_hacking_team_id"
    t.index ["kind"], name: "index_users_on_kind"
  end

  create_table "votes", force: :cascade do |t|
    t.float "mark"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed", default: false
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "ethereum_addresses", "users"
  add_foreign_key "join_applications", "hacking_teams"
  add_foreign_key "join_applications", "users"
  add_foreign_key "join_applications", "users", column: "decided_by_id"
  add_foreign_key "judgements", "judging_teams"
  add_foreign_key "judgements", "submissions"
  add_foreign_key "judgements", "votes", column: "concept_vote_id", on_delete: :nullify
  add_foreign_key "judgements", "votes", column: "product_vote_id", on_delete: :nullify
  add_foreign_key "judgements", "votes", column: "technical_vote_id", on_delete: :nullify
  add_foreign_key "judging_teams", "judgements", column: "current_judgement_id", on_delete: :nullify
  add_foreign_key "judging_teams", "users", column: "concept_judge_id"
  add_foreign_key "judging_teams", "users", column: "product_judge_id"
  add_foreign_key "judging_teams", "users", column: "technical_judge_id"
  add_foreign_key "submissions", "hacking_teams"
  add_foreign_key "users", "hacking_teams", on_delete: :nullify
  add_foreign_key "votes", "users"
end
