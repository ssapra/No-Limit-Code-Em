# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121009210650) do

  create_table "change_logs", :force => true do |t|
    t.integer "record_id"
    t.text    "table_name"
    t.text    "column_name"
    t.text    "old_value"
    t.text    "new_value"
  end

  create_table "hand_logs", :force => true do |t|
    t.integer  "hand_id"
    t.integer  "table_id"
    t.text     "players_ids"
    t.integer  "dealer_seat_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "player_action_logs", :force => true do |t|
    t.integer  "hand_id"
    t.integer  "player_id"
    t.string   "action"
    t.integer  "amount"
    t.string   "cards"
    t.string   "comment"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "betting_round_id"
  end

  create_table "player_state_logs", :force => true do |t|
    t.integer  "hand_id"
    t.integer  "player_id"
    t.integer  "chip_count"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "players", :force => true do |t|
    t.integer  "game_id"
    t.string   "name"
    t.string   "player_key"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.text     "hand",        :default => "'"
    t.integer  "bet",         :default => 0
    t.integer  "stack",       :default => 500
    t.string   "action"
    t.boolean  "in_game",     :default => true
    t.boolean  "in_round",    :default => true
    t.boolean  "turn",        :default => false
    t.integer  "table_id"
    t.integer  "seat_id"
    t.boolean  "replacement"
    t.datetime "losing_time"
  end

  add_index "players", ["name"], :name => "index_players_on_name"

  create_table "pots", :force => true do |t|
    t.integer  "total"
    t.integer  "round_id"
    t.text     "player_ids"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rounds", :force => true do |t|
    t.integer  "pot"
    t.integer  "min_bet"
    t.boolean  "first_bet"
    t.boolean  "second_bet"
    t.integer  "table_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "seats", :force => true do |t|
    t.integer  "table_id"
    t.integer  "player_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "statuses", :force => true do |t|
    t.boolean  "registration"
    t.boolean  "game"
    t.boolean  "play"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.boolean  "tournament"
    t.boolean  "waiting"
  end

  create_table "tables", :force => true do |t|
    t.integer  "pot"
    t.text     "deck"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "turn_id"
    t.integer  "min_bet"
    t.integer  "betting_round"
    t.integer  "placeholder_id"
    t.integer  "dealer_id"
    t.boolean  "game_over"
    t.boolean  "waiting"
  end

end
