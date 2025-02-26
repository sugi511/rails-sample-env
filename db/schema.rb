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

ActiveRecord::Schema.define(version: 2025_02_23_152719) do

  create_table "answers", force: :cascade do |t|
    t.integer "survey_id"
    t.integer "question_id"
    t.string "answer", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["survey_id"], name: "index_answers_on_survey_id"
  end

  create_table "api_request_logs", force: :cascade do |t|
    t.integer "company_id"
    t.integer "user_id"
    t.string "path", default: "", null: false
    t.string "controller", default: "", null: false
    t.string "action", default: "", null: false
    t.json "request_body", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "method", default: "", null: false
    t.integer "status", default: 0
    t.string "limit_status", default: "none", null: false
    t.index ["company_id"], name: "index_api_request_logs_on_company_id"
    t.index ["created_at"], name: "index_api_request_logs_on_created_at"
    t.index ["user_id"], name: "index_api_request_logs_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "daily_request_limit_api", default: 100
  end

  create_table "customers", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "region_id"
    t.index ["company_id"], name: "index_customers_on_company_id"
    t.index ["region_id"], name: "index_customers_on_region_id"
  end

  create_table "gcra_settings", force: :cascade do |t|
    t.integer "company_id"
    t.string "name", default: "Limitatio in 10 mins", null: false
    t.integer "bucket_size", default: 10, null: false
    t.integer "emission_interval", default: 2, null: false
    t.datetime "tat", default: "2000-01-01 00:00:00", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_gcra_settings_on_company_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "company_id"
    t.string "question", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_questions_on_company_id"
  end

  create_table "region_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "region_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "region_desc_idx"
  end

  create_table "regions", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", default: "", null: false
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_regions_on_company_id"
    t.index ["parent_id"], name: "index_regions_on_parent_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.integer "company_id"
    t.integer "customer_id"
    t.integer "user_id"
    t.text "note", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_surveys_on_company_id"
    t.index ["customer_id"], name: "index_surveys_on_customer_id"
    t.index ["user_id"], name: "index_surveys_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", default: "", null: false
    t.string "api_key", default: "", null: false
    t.string "api_secret", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "otp_secret", default: "", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "surveys"
  add_foreign_key "api_request_logs", "companies"
  add_foreign_key "api_request_logs", "users"
  add_foreign_key "customers", "companies"
  add_foreign_key "customers", "regions"
  add_foreign_key "gcra_settings", "companies"
  add_foreign_key "questions", "companies"
  add_foreign_key "regions", "companies"
  add_foreign_key "regions", "regions", column: "parent_id"
  add_foreign_key "surveys", "companies"
  add_foreign_key "surveys", "customers"
  add_foreign_key "surveys", "users"
  add_foreign_key "users", "companies"
end
