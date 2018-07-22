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

ActiveRecord::Schema.define(version: 2018_07_22_110026) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conversions", force: :cascade do |t|
    t.string "ynab_budget_id"
    t.string "ynab_account_id"
    t.string "cached_ynab_account_name"
    t.string "cached_ynab_budget_name"
    t.string "from_currency"
    t.string "to_currency"
    t.datetime "synced_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.string "from"
    t.string "to"
    t.float "rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "syncs", force: :cascade do |t|
    t.bigint "conversion_id"
    t.text "transactions"
    t.boolean "confirmed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversion_id"], name: "index_syncs_on_conversion_id"
  end

end
