# -*- encoding : utf-8 -*-

class RemoveLegacyTables < Cardio::Migration::Schema
  def up
    # drop_table :card_revisions
    # drop_table :users
    # drop_table :sessions
    remove_column :cards, :current_revision_id
    remove_column :cards, :references_expired
  end
end
