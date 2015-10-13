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

ActiveRecord::Schema.define(version: 20151013064258) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",    limit: 4, null: false
    t.integer  "post_id",    limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "bookmarks", ["post_id"], name: "index_bookmarks_on_post_id", using: :btree
  add_index "bookmarks", ["user_id", "post_id"], name: "index_bookmarks_on_user_id_and_post_id", unique: true, using: :btree
  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "post_id",     limit: 4,   null: false
    t.integer  "user_id",     limit: 4,   null: false
    t.integer  "reply_to_id", limit: 4
    t.string   "content",     limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "comments", ["post_id"], name: "index_comments_on_post_id", using: :btree
  add_index "comments", ["reply_to_id"], name: "index_comments_on_reply_to_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "infections", force: :cascade do |t|
    t.integer  "user_id",      limit: 4,                 null: false
    t.integer  "post_id",      limit: 4,                 null: false
    t.integer  "post_view_id", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "active",                 default: false, null: false
  end

  add_index "infections", ["post_id"], name: "index_infections_on_post_id", using: :btree
  add_index "infections", ["post_view_id"], name: "index_infections_on_post_view_id", using: :btree
  add_index "infections", ["user_id"], name: "index_infections_on_user_id", using: :btree

  create_table "post_pages", force: :cascade do |t|
    t.integer  "post_id",    limit: 4,   null: false
    t.integer  "order",      limit: 4,   null: false
    t.string   "image",      limit: 255
    t.string   "text",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "post_pages", ["post_id"], name: "index_post_pages_on_post_id", using: :btree

  create_table "post_views", force: :cascade do |t|
    t.integer  "infection_id", limit: 4, null: false
    t.integer  "result",       limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "post_views", ["infection_id"], name: "index_post_views_on_infection_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id",        limit: 4,             null: false
    t.integer  "comments_count", limit: 4, default: 0, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "views_count",    limit: 4, default: 0, null: false
    t.integer  "spreads_count",  limit: 4, default: 0, null: false
  end

  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "user_security_codes", force: :cascade do |t|
    t.string   "username",      limit: 48
    t.string   "security_code", limit: 255
    t.boolean  "verified",                  default: false, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "user_security_codes", ["username"], name: "index_user_security_codes_on_username", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",              limit: 48
    t.string   "nickname",              limit: 48
    t.string   "password_digest",       limit: 255
    t.string   "avatar",                limit: 255
    t.string   "biography",             limit: 255
    t.integer  "gender",                limit: 4,   default: 0,    null: false
    t.integer  "can_infect",            limit: 4,   default: 0,    null: false
    t.integer  "infection_index",       limit: 4,   default: 0,    null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "access_token",          limit: 48
    t.boolean  "notifications_enabled",             default: true, null: false
  end

  add_index "users", ["nickname"], name: "index_users_on_nickname", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "bookmarks", "posts"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "comments", "comments", column: "reply_to_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "infections", "post_views"
  add_foreign_key "infections", "posts"
  add_foreign_key "infections", "users"
  add_foreign_key "post_pages", "posts"
  add_foreign_key "post_views", "infections"
  add_foreign_key "posts", "users"
end
