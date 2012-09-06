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

ActiveRecord::Schema.define(:version => 20120906205347) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "inputs", :force => true do |t|
    t.string   "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "players", :force => true do |t|
    t.integer  "game_id"
    t.string   "name"
    t.string   "player_key"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.text     "hand",        :limit => 255, :default => "'"
    t.integer  "bet",                        :default => 0
    t.integer  "stack",                      :default => 500
    t.string   "action"
    t.boolean  "in_game",                    :default => true
    t.boolean  "in_round",                   :default => true
    t.boolean  "turn",                       :default => false
    t.integer  "table_id"
    t.integer  "seat_id"
    t.boolean  "replacement"
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
  end

  create_table "tables", :force => true do |t|
    t.integer  "pot"
    t.text     "deck"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "turn_id"
    t.integer  "min_bet"
  end

end
