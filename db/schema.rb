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

ActiveRecord::Schema[8.1].define(version: 2026_08_05_041960) do
  create_table "answers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "clarification_id", null: false
    t.boolean "collective", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["clarification_id"], name: "index_answers_on_clarification_id", unique: true
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "clarifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "problem_id", null: false
    t.text "question", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["problem_id"], name: "index_clarifications_on_problem_id"
    t.index ["user_id"], name: "index_clarifications_on_user_id"
  end

  create_table "contests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.datetime "published_at"
    t.datetime "started_at"
    t.datetime "updated_at", null: false
  end

  create_table "deliveries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "problem_id", null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["problem_id"], name: "index_deliveries_on_problem_id"
    t.index ["staff_id"], name: "index_deliveries_on_staff_id"
    t.index ["user_id", "problem_id"], name: "index_deliveries_on_user_id_and_problem_id", unique: true
    t.index ["user_id"], name: "index_deliveries_on_user_id"
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

  add_foreign_key "answers", "clarifications"
  add_foreign_key "answers", "users"
  add_foreign_key "clarifications", "problems"
  add_foreign_key "clarifications", "users"
  add_foreign_key "deliveries", "problems"
  add_foreign_key "deliveries", "users"
  add_foreign_key "deliveries", "users", column: "staff_id"
  add_foreign_key "problems", "contests"
  add_foreign_key "sessions", "users"
  add_foreign_key "submissions", "problems"
  add_foreign_key "submissions", "users"
  add_foreign_key "testcases", "problems"
end
