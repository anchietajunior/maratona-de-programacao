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

ActiveRecord::Schema[8.1].define(version: 2026_08_02_204703) do
  create_table "contests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.datetime "started_at"
    t.datetime "updated_at", null: false
  end

  create_table "problems", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "contest_id", null: false
    t.datetime "created_at", null: false
    t.string "difficulty", null: false
    t.integer "position", null: false
    t.text "reference_solution", null: false
    t.text "statement", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["contest_id", "position"], name: "index_problems_on_contest_id_and_position", unique: true
    t.index ["contest_id"], name: "index_problems_on_contest_id"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "last_active_at", default: -> { "CURRENT_TIMESTAMP(6)" }, null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "submissions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "code", null: false
    t.datetime "created_at", null: false
    t.bigint "problem_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "verdict"
    t.index ["problem_id"], name: "index_submissions_on_problem_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "testcases", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.binary "expected_output", null: false
    t.binary "input", null: false
    t.bigint "problem_id", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id"], name: "index_testcases_on_problem_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "nickname", null: false
    t.string "password_digest", null: false
    t.boolean "staff", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
  end

  add_foreign_key "problems", "contests"
  add_foreign_key "sessions", "users"
  add_foreign_key "submissions", "problems"
  add_foreign_key "submissions", "users"
  add_foreign_key "testcases", "problems"
end
