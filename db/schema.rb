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

ActiveRecord::Schema[7.1].define(version: 2024_04_09_192041) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "user_type", ["Hacker", "Judge", "Organizer"]

  create_table "ethereum_addresses", force: :cascade do |t|
    t.string "address"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_ethereum_addresses_on_address"
    t.index ["user_id"], name: "index_ethereum_addresses_on_user_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "github_handle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "type", default: "Hacker", null: false, enum_type: "user_type"
    t.index ["type"], name: "index_users_on_type"
  end

  create_table "votes", force: :cascade do |t|
    t.float "mark"
    t.bigint "user_id", null: false
    t.bigint "submission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_votes_on_submission_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "ethereum_addresses", "users"
  add_foreign_key "votes", "submissions"
  add_foreign_key "votes", "users"
end
