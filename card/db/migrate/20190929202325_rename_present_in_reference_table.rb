class RenamePresentInReferenceTable < ActiveRecord::Migration[4.2]
  def up
    rename_column :card_references, :present, :is_present
  end

  def down
    rename_column :card_references, :is_present, :present
  end
end
