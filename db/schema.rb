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

ActiveRecord::Schema.define(version: 2019_08_22_192827) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "author_id"
    t.string "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.text "body"
    t.text "heading"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "saved"
  end

  create_table "games", force: :cascade do |t|
    t.integer "week_id"
    t.integer "user_id"
    t.integer "points"
    t.boolean "is_home_team"
    t.float "spread"
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.integer "home_team_pref_pick"
    t.integer "away_team_pref_pick"
    t.boolean "home_team_spread_pick"
    t.boolean "away_team_spread_pick"
    t.boolean "home_team_covered_spread"
    t.boolean "away_team_covered_spread"
    t.boolean "tie_game"
    t.boolean "game_selected_by_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "game_is_active"
    t.integer "home_team_spread"
    t.integer "home_team_score"
    t.integer "away_team_score"
    t.boolean "home_team_won_straight_up"
    t.boolean "away_team_won_straight_up"
    t.integer "team_that_won_straight_up"
    t.integer "team_that_covered_spread"
    t.boolean "active"
    t.string "bowl_game_name"
    t.boolean "has_game_been_scored", default: false
    t.boolean "hidden", default: false
    t.index ["user_id"], name: "index_games_on_user_id"
    t.index ["week_id"], name: "index_games_on_week_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "user_id"
    t.string "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "points", force: :cascade do |t|
    t.integer "user_id"
    t.integer "week_id"
    t.integer "cumulative_points", default: 0
    t.integer "integer", default: 0
    t.integer "weekly_points", default: 0
    t.integer "weekly_points_game_a", default: 0
    t.integer "weekly_points_game_b", default: 0
  end

  create_table "scores", force: :cascade do |t|
    t.integer "week_id"
    t.integer "user_id"
    t.integer "game_a"
    t.integer "game_b"
    t.integer "points_for_week"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "selections", force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.boolean "correct"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "points"
    t.integer "pref_pick_int"
    t.string "pref_pick_str"
    t.integer "spread_pick"
    t.integer "pref_pick_team"
    t.integer "spread_pick_team"
    t.integer "week_id"
    t.boolean "correct_spread_pick"
    t.boolean "correct_pref_pick"
  end

  create_table "teams", force: :cascade do |t|
    t.integer "tid"
    t.integer "cid"
    t.integer "did"
    t.string "region"
    t.string "name"
    t.string "abbrev"
    t.string "city"
    t.string "state"
    t.float "latitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "name"
    t.string "nickname"
    t.boolean "admin", default: false
    t.text "address"
    t.string "fav_teams"
    t.string "cell_phone_number"
    t.integer "weekly_points", default: 0
    t.integer "cumulative_points", default: 0
    t.integer "weekly_points_game_a", default: 0
    t.integer "weekly_points_game_b", default: 0
    t.boolean "active"
    t.integer "total_weekly_points", default: 0
    t.integer "last_week_score", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "weeks", force: :cascade do |t|
    t.string "week_number"
    t.string "year"
    t.datetime "year_in_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "active"
  end

end
