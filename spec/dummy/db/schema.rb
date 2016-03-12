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

ActiveRecord::Schema.define(version: 20141110200841) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: true do |t|
    t.string   "name",                                       null: false
    t.string   "phone_number",                               null: false
    t.string   "website",                                    null: false
    t.string   "email",                                      null: false
    t.string   "address_1",                                  null: false
    t.string   "address_2"
    t.string   "city",                                       null: false
    t.string   "state",                                      null: false
    t.string   "zipcode",                                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "company_logo_includes_name", default: false, null: false
    t.boolean  "app_logo_includes_name",     default: false, null: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
    t.string   "device_id"
    t.string   "current_device_type"
    t.string   "current_mac_address"
    t.float    "longitude"
    t.float    "latitude"
    t.boolean  "account_verified",       default: false, null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "mobile_phone"
    t.string   "facebook_id"
    t.text     "facebook_access_token"
    t.datetime "facebook_expires_at"
    t.string   "twitter_id"
    t.string   "twitter_access_token"
    t.string   "twitter_access_secret"
    t.string   "timezone"
    t.string   "provider_avatar"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "mobile_client_platform"
    t.string   "mobile_client_version"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["first_name"], name: "index_users_on_first_name", using: :btree
  add_index "users", ["last_name"], name: "index_users_on_last_name", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
