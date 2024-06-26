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

ActiveRecord::Schema[7.0].define(version: 2024_06_23_124444) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_admins_on_name", unique: true
  end

  create_table "attendances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "date", null: false
    t.time "clock_in_time"
    t.time "clock_out_time"
    t.integer "working_minutes", default: 0, null: false
    t.integer "overtime_minutes", default: 0, null: false
    t.integer "hourly_wage", default: 0, null: false
    t.integer "transport_cost", default: 0, null: false
    t.integer "allowance", default: 0, null: false
    t.integer "total_payment", default: 0, null: false
    t.boolean "special_day", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_working_minutes", default: 0, null: false
    t.integer "daily_wage", default: 0, null: false
    t.integer "overtime_pay", default: 0, null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "special_days", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "description", null: false
    t.integer "wage_increment", default: 0, null: false
    t.integer "allowance", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "last_name", null: false
    t.string "first_name", null: false
    t.string "last_name_kana", null: false
    t.string "first_name_kana", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "weekday_hourly_wage", default: 0, null: false
    t.integer "weekend_hourly_wage", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wages_on_user_id"
  end

  add_foreign_key "attendances", "users"
  add_foreign_key "wages", "users"
end
