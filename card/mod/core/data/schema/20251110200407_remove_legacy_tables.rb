# -*- encoding : utf-8 -*-

class RemoveLegacyTables < Cardio::Migration::Schema
  def up
    drop_table :card_revisions, if_exists: true
    drop_table :users, if_exists: true
    drop_table :sessions, if_exists: true
    remove_column_with_rescue :cards, :current_revision_id
    remove_column_with_rescue :cards, :references_expired
  end

  def remove_column_with_rescue *args
    remove_column *args
  rescue StandardError
    puts "failed to remove column #{args}"
  end
end
