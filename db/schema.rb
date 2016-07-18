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

ActiveRecord::Schema.define(version: 20160718215309) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blockeds", force: true do |t|
    t.integer  "user_id"
    t.integer  "blocked_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blockeds", ["user_id"], name: "index_blockeds_on_user_id", using: :btree

  create_table "chatimages", force: true do |t|
    t.string   "img"
    t.integer  "chat_id"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chatimages", ["chat_id"], name: "index_chatimages_on_chat_id", using: :btree

  create_table "chats", force: true do |t|
    t.string   "chat_msg"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chatimage_id"
    t.boolean  "seen",            default: false
    t.boolean  "receiver_delete", default: false
    t.boolean  "sender_delete",   default: false
  end

  create_table "chats_users", id: false, force: true do |t|
    t.integer "chat_id"
    t.integer "user_id"
  end

  add_index "chats_users", ["chat_id", "user_id"], name: "index_chats_users_on_chat_id_and_user_id", using: :btree

  create_table "favourites", force: true do |t|
    t.integer  "user_id"
    t.integer  "fav_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favourites", ["user_id"], name: "index_favourites_on_user_id", using: :btree

  create_table "fsettings", force: true do |t|
    t.integer  "user_id"
    t.string   "show_me_of_gender_with_interest", default: "Everybody"
    t.string   "show_me_close_to",                default: "SHOW_ME_CLOSE_TO_WORLD"
    t.string   "show_me_of_age_min",              default: "18"
    t.string   "show_me_of_age_max",              default: "45"
    t.string   "show_me_of_city"
    t.string   "show_me_of_ethnicity",            default: "ALL"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fsettings", ["user_id"], name: "index_fsettings_on_user_id", using: :btree

  create_table "images", force: true do |t|
    t.string   "img"
    t.integer  "user_id"
    t.integer  "user_img_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order",          default: 0
  end

  add_index "images", ["user_id"], name: "index_images_on_user_id", using: :btree

  create_table "notifications", force: true do |t|
    t.string   "notification_type"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "seen",              default: false
  end

  add_index "notifications", ["receiver_id"], name: "index_notifications_on_receiver_id", using: :btree

  create_table "nsettings", force: true do |t|
    t.integer  "user_id"
    t.boolean  "favorite_me",      default: true
    t.boolean  "msg_alert",        default: true
    t.boolean  "wingle_alert",     default: true
    t.boolean  "member_alert",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sound",            default: true
    t.boolean  "vibrate",          default: true
    t.boolean  "led",              default: true
    t.boolean  "show_my_location", default: true
    t.boolean  "checked_me_out",   default: false
  end

  add_index "nsettings", ["user_id"], name: "index_nsettings_on_user_id", using: :btree

  create_table "pokes", force: true do |t|
    t.integer  "user_id"
    t.integer  "poke_count",    default: 0
    t.integer  "poked_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pokes", ["user_id"], name: "index_pokes_on_user_id", using: :btree

  create_table "userinfos", force: true do |t|
    t.integer  "user_id"
    t.string   "gender",          default: ""
    t.string   "height",          default: "Ask me"
    t.string   "ethnicity",       default: "Ask me"
    t.string   "body_type",       default: "Ask me"
    t.string   "relation_status", default: "Ask me"
    t.string   "interested_in"
    t.string   "about_me",        default: ""
    t.string   "wingle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.string   "country"
    t.string   "headline",        default: ""
    t.string   "address"
    t.datetime "birthday"
  end

  add_index "userinfos", ["user_id"], name: "index_userinfos_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "surname"
    t.string   "authentication_token"
    t.string   "login_type"
    t.float    "latitude",               default: 0.0
    t.float    "longitude",              default: 0.0
    t.string   "gcm_token"
    t.string   "image_id"
    t.string   "image_no"
    t.boolean  "is_account_active",      default: true
    t.integer  "imagecount",             default: 0
    t.string   "resettoken"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
