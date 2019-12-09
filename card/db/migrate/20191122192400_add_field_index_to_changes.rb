class AddFieldIndexToChanges < ActiveRecord::Migration[6.0]
  def up
    add_index :card_changes, :field, name: "card_changes_field"
  end

  def down
    remove_index :card_changes, "card_changes_field"
  end
end
