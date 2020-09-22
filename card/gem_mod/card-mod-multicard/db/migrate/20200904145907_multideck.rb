class Multideck < ActiveRecord::Migration[6.0]
  def change
warn " change multideck"
=begin
    add_column :cards, :deck_id, :integer, default: 1
    add_column :cards, :card_id, :integer
    add_column :cards, :act_id, :integer
    add_column :cards, :language_id, :integer, default: nil

    add_column :card_references, :decker_id, :integer, default: 1
    add_column :card_references, :deckee_id, :integer, default: 1

    remove_index :card_references, ["referee_id"], name: "card_references_referee_id_index"
    remove_index :card_references, ["referee_key"], name: "card_references_referee_key_index"
    remove_index :card_references, ["referer_id"], name: "card_references_referer_id_index"
    remove_index :cards, column: ['key'], name: "cards_key_index"
    remove_index :cards, column: ["codename"], name: "cards_codename_index"
    remove_index :cards, column: ["created_at"], name: "cards_created_at_index"
    remove_index :cards, column: ["left_id"], name: "cards_left_id_index"
    remove_index :cards, column: ["name"], name: "cards_name_index"
    remove_index :cards, column: ["read_rule_id"], name: "cards_read_rule_id_index"
    remove_index :cards, column: ["right_id"], name: "cards_right_id_index"
    remove_index :cards, column: ["type_id"], name: "cards_type_id_index"
    remove_index :cards, column: ["updated_at"], name: "cards_updated_at_index"

    Card.update(card_id: :id)

    add_index :card_references, ["referee_id", 'deckee_id'], name: "card_references_referee_id_index"
    add_index :card_references, ["referee_key", 'deckee_id'], name: "card_references_referee_key_index"
    add_index :card_references, ["referer_id", 'decker_id'], name: "card_references_referer_id_index"

    add_index :cards, ['key', 'deck_id', 'language_id'], name: "cards_key_index", unique: true
    add_index :cards, ["codename"], name: "cards_codename_index"
    add_index :cards, ["created_at", 'deck_id', 'language_id'], name: "cards_created_at_index"
    add_index :cards, ["left_id", 'deck_id', 'language_id'], name: "cards_left_id_index"
    add_index :cards, ["name", 'deck_id', 'language_id'], name: "cards_name_index"
    add_index :cards, ["read_rule_id", 'deck_id', 'language_id'], name: "cards_read_rule_id_index"
    add_index :cards, ["right_id", 'deck_id', 'language_id'], name: "cards_right_id_index"
    add_index :cards, ["type_id", 'deck_id', 'language_id'], name: "cards_type_id_index"
    add_index :cards, ["updated_at", 'deck_id', 'language_id'], name: "cards_updated_at_index"

    create_table "cards", id: :integer, force: :cascade do |t|
      t.integer "deck_id"
      t.integer "card_id"
      t.integer "act_id"
      t.integer "language_id"
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
      t.text "db_content", size: :medium
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
=end
  end
end
