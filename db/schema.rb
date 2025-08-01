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

ActiveRecord::Schema[8.0].define(version: 2025_08_01_055215) do
  create_table "measurements", force: :cascade do |t|
    t.integer "gestational_weeks", null: false
    t.integer "gestational_days", null: false
    t.string "gender", null: false
    t.float "height", null: false
    t.float "weight", null: false
    t.float "head_circumference", null: false
    t.float "height_z"
    t.float "weight_z"
    t.float "hc_z"
    t.float "height_percentile"
    t.float "weight_percentile"
    t.float "hc_percentile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "newborns", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "patronymic"
    t.string "gender", limit: 1
    t.float "gestational_age"
    t.string "delivery_method"
    t.date "birth_date"
    t.date "admission_date"
    t.date "discharge_date"
    t.string "outcome"
    t.float "birth_weight"
    t.float "discharge_weight"
    t.float "birth_height"
    t.integer "apgar_1"
    t.integer "apgar_5"
    t.string "hepatitis_b"
    t.string "bcg"
    t.string "icd_code"
    t.string "hiv"
    t.string "fetopathy"
    t.string "feeding"
    t.string "comorbidities"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
