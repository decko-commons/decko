class RemovePresentFromReferenceTable < ActiveRecord::Migration[4.2]
  def up
    # remove_column :card_references, :present
  end

  def down
    # add_column :card_references, :present, :integer
  end
end
