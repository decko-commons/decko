class BetterIndexNames < Cardio::Migration::Schema
  def up
    rename_index :card_acts, "actor_id_index", "card_acts_actor_id_index"
    rename_index :card_acts, "card_id_index",  "card_acts_card_id_index"

    rename_index :card_actions, "card_act_id_index", "card_actions_card_act_id_index"
    rename_index :card_actions, "card_id_index",     "card_actions_card_id_index"

    rename_index :card_changes, "card_action_id_index",
                 "card_changes_card_action_id_index"

    rename_index :card_references, "wiki_references_referenced_card_id",
                 "card_references_referee_id_index"
    rename_index :card_references, "wiki_references_referenced_name",
                 "card_references_referee_key_index"
    rename_index :card_references, "wiki_references_card_id",
                 "card_references_referer_id_index"

    rename_index :cards, "cards_key_uniq",              "cards_key_index"
    rename_index :cards, "card_type_index",             "cards_type_id_index"
    rename_index_robustly :trunk, :left
    rename_index_robustly :tag, :right
    rename_index_robustly :read_rule, :read_rule
  end

  def rename_index_robustly old, new
    rename_index :cards, "index_cards_on_#{old}_id", "cards_#{new}_id_index"
  rescue ActiveRecord::StatementInvalid
    rename_index :cards, "index_cards_on_#{new}_id", "cards_#{new}_id_index"
  end

  def down; end
end
