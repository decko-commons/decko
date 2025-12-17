# -*- encoding : utf-8 -*-

class RemoveLegacyTables < Cardio::Migration::Schema
  def up
    drop_table :card_revisions, if_exists: true
    drop_table :users, if_exists: true
    drop_table :sessions, if_exists: true
    remove_column :cards, :current_revision_id
    remove_column :cards, :references_expired
  end
end
