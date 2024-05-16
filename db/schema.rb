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

ActiveRecord::Schema[7.1].define(version: 2024_05_16_194903) do
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
    t.time "time"
    t.boolean "no_show", default: false, null: false
    t.index ["concept_vote_id"], name: "index_judgements_on_concept_vote_id"
    t.index ["judging_team_id"], name: "index_judgements_on_judging_team_id"
    t.index ["product_vote_id"], name: "index_judgements_on_product_vote_id"
    t.index ["submission_id"], name: "index_judgements_on_submission_id"
    t.index ["technical_vote_id"], name: "index_judgements_on_technical_vote_id"
    t.index ["time"], name: "index_judgements_on_time"
  end

  create_table "judging_breaks", force: :cascade do |t|
    t.time "begins", null: false
    t.time "ends", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["begins"], name: "index_judging_breaks_on_begins"
    t.index ["ends"], name: "index_judging_breaks_on_ends"
  end

  create_table "judging_teams", force: :cascade do |t|
    t.enum "track", null: false, enum_type: "judging_track"
    t.bigint "technical_judge_id"
    t.bigint "product_judge_id"
    t.bigint "concept_judge_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location"
    t.index ["concept_judge_id"], name: "index_judging_teams_on_concept_judge_id"
    t.index ["product_judge_id"], name: "index_judging_teams_on_product_judge_id"
    t.index ["technical_judge_id"], name: "index_judging_teams_on_technical_judge_id"
  end

  create_table "que_jobs", comment: "7", force: :cascade do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.timestamptz "run_at", default: -> { "now()" }, null: false
    t.text "job_class", null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error_message"
    t.text "queue", default: "default", null: false
    t.text "last_error_backtrace"
    t.timestamptz "finished_at"
    t.timestamptz "expired_at"
    t.jsonb "args", default: [], null: false
    t.jsonb "data", default: {}, null: false
    t.integer "job_schema_version", null: false
    t.jsonb "kwargs", default: {}, null: false
    t.index ["args"], name: "que_jobs_args_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.index ["data"], name: "que_jobs_data_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.index ["job_schema_version", "queue", "priority", "run_at", "id"], name: "que_poll_idx", where: "((finished_at IS NULL) AND (expired_at IS NULL))"
    t.index ["kwargs"], name: "que_jobs_kwargs_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.check_constraint "char_length(\nCASE job_class\n    WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'::text THEN (args -> 0) ->> 'job_class'::text\n    ELSE job_class\nEND) <= 200", name: "job_class_length"
    t.check_constraint "char_length(last_error_message) <= 500 AND char_length(last_error_backtrace) <= 10000", name: "error_length"
    t.check_constraint "char_length(queue) <= 100", name: "queue_length"
    t.check_constraint "jsonb_typeof(args) = 'array'::text", name: "valid_args"
    t.check_constraint "jsonb_typeof(data) = 'object'::text AND (NOT data ? 'tags'::text OR jsonb_typeof(data -> 'tags'::text) = 'array'::text AND jsonb_array_length(data -> 'tags'::text) <= 5 AND que_validate_tags(data -> 'tags'::text))", name: "valid_data"
  end

  create_table "que_lockers", primary_key: "pid", id: :integer, default: nil, force: :cascade do |t|
    t.integer "worker_count", null: false
    t.integer "worker_priorities", null: false, array: true
    t.integer "ruby_pid", null: false
    t.text "ruby_hostname", null: false
    t.text "queues", null: false, array: true
    t.boolean "listening", null: false
    t.integer "job_schema_version", default: 1
    t.check_constraint "array_ndims(queues) = 1 AND array_length(queues, 1) IS NOT NULL", name: "valid_queues"
    t.check_constraint "array_ndims(worker_priorities) = 1 AND array_length(worker_priorities, 1) IS NOT NULL", name: "valid_worker_priorities"
  end

  create_table "que_values", primary_key: "key", id: :text, force: :cascade do |t|
    t.jsonb "value", default: {}, null: false
    t.check_constraint "jsonb_typeof(value) = 'object'::text", name: "valid_value"
  end

  create_table "settings", primary_key: "key", id: :string, force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "hacking_team_id"
    t.enum "track", default: "infra", null: false, enum_type: "judging_track"
    t.index ["hacking_team_id"], name: "index_submissions_on_hacking_team_id"
    t.index ["track"], name: "index_submissions_on_track"
  end

  create_table "ticket_invalidations", id: false, force: :cascade do |t|
    t.uuid "ticket_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_ticket_invalidations_on_ticket_id", unique: true
    t.index ["user_id"], name: "index_ticket_invalidations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "github_handle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "kind", default: "hacker", null: false, enum_type: "user_kind"
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.index ["approved_by_id"], name: "index_users_on_approved_by_id"
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
  add_foreign_key "judging_teams", "users", column: "concept_judge_id"
  add_foreign_key "judging_teams", "users", column: "product_judge_id"
  add_foreign_key "judging_teams", "users", column: "technical_judge_id"
  add_foreign_key "submissions", "hacking_teams"
  add_foreign_key "ticket_invalidations", "users"
  add_foreign_key "users", "users", column: "approved_by_id"
  add_foreign_key "votes", "users"
end
