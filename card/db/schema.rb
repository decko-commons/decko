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
#
# Remark: We used to use size: medium for text columns. This option is supported by mysql but not by postgres.
# limit: 16.megabytes - 1 translates to the same size in mysql databases.


ActiveRecord::Schema.define(version: 2022_10_31_182227) do

  create_table "card_actions", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "card_id"
    t.integer "card_act_id"
    t.integer "super_action_id"
    t.integer "action_type"
    t.boolean "draft"
    t.text "comment"
    t.index ["card_act_id"], name: "card_actions_card_act_id_index"
    t.index ["card_id"], name: "card_actions_card_id_index"
  end

  create_table "card_acts", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "card_id"
    t.integer "actor_id"
    t.datetime "acted_at"
    t.string "ip_address"
    t.index ["acted_at"], name: "acts_acted_at_index"
    t.index ["actor_id"], name: "card_acts_actor_id_index"
    t.index ["card_id"], name: "card_acts_card_id_index"
  end

  create_table "card_changes", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "card_action_id"
    t.integer "field"
    t.text "value", limit: 16.megabytes - 1
    t.index ["card_action_id"], name: "card_changes_card_action_id_index"
  end

  create_table "card_references", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "referer_id", default: 0, null: false
    t.string "referee_key", default: ""
    t.integer "referee_id"
    t.string "ref_type", limit: 1, default: "", null: false
    t.integer "is_present"
    t.index ["ref_type"], name: "card_references_ref_type_index"
    t.index ["referee_id"], name: "card_references_referee_id_index"
    t.index ["referee_key"], name: "card_references_referee_key_index"
    t.index ["referer_id"], name: "card_references_referer_id_index"
  end

  create_table "card_revisions", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "card_id", null: false
    t.integer "creator_id", null: false
    t.text "content", null: false
    t.index ["card_id"], name: "revisions_card_id_index"
    t.index ["creator_id"], name: "revisions_created_by_index"
  end

  create_table "card_virtuals", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "left_id"
    t.integer "right_id"
    t.string "left_key"
    t.text "content", limit: 16.megabytes - 1
    t.datetime "updated_at"
    t.index ["left_id"], name: "right_id_index"
    t.index ["right_id"], name: "left_id_index"
  end

  create_table "cards", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.string "codename"
    t.integer "left_id"
    t.integer "right_id"
    t.integer "current_revision_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id", null: false
    t.integer "updater_id", null: false
    t.string "read_rule_class"
    t.integer "read_rule_id"
    t.integer "references_expired"
    t.boolean "trash", null: false
    t.integer "type_id", null: false
    t.text "db_content", limit: 16.megabytes - 1
    t.index ["codename"], name: "cards_codename_index"
    t.index ["created_at"], name: "cards_created_at_index"
    t.index ["key"], name: "cards_key_index", unique: true
    t.index ["left_id"], name: "cards_left_id_index"
    t.index ["name"], name: "cards_name_index"
    t.index ["read_rule_id"], name: "cards_read_rule_id_index"
    t.index ["right_id"], name: "cards_right_id_index"
    t.index ["type_id"], name: "cards_type_id_index"
    t.index ["updated_at"], name: "cards_updated_at_index"
  end

  create_table "delayed_jobs", charset: "utf8mb3", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", limit: 16.megabytes - 1, null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "sessions", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "session_id"
    t.text "data"
    t.datetime "updated_at"
    t.index ["session_id"], name: "sessions_session_id_index"
  end

  create_table "transform_migrations", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.string "version", null: false
    t.index ["version"], name: "unique_schema_migrations_cards", unique: true
  end

  create_table "users", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "login", limit: 40
    t.string "email", limit: 100
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 42
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "password_reset_code", limit: 40
    t.string "status", default: "request"
    t.integer "invite_sender_id"
    t.string "identity_url"
    t.integer "card_id", null: false
    t.integer "account_id", null: false
  end

end
