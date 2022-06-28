# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_06_27_074042) do

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
    t.index ["company_id"], name: "index_customers_on_company_id"
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

end
