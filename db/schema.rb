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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150903082637) do

  create_table "user_security_codes", force: :cascade do |t|
    t.string   "username",      limit: 48
    t.string   "security_code", limit: 255
    t.boolean  "verified",                  default: false, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "user_security_codes", ["username"], name: "index_user_security_codes_on_username", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 48
    t.string   "nickname",        limit: 48
    t.string   "password_digest", limit: 255
    t.string   "avatar",          limit: 255
    t.string   "biography",       limit: 255
    t.integer  "gender",          limit: 4
    t.integer  "can_infect",      limit: 4,   default: 0, null: false
    t.integer  "infection_index", limit: 4,   default: 0, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "access_token",    limit: 48
  end

  add_index "users", ["nickname"], name: "index_users_on_nickname", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
