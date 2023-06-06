class RemovePresentFromReferenceTable < Cardio::Migration::Schema
  def up
    # remove_column :card_references, :present
  end

  def down
    # add_column :card_references, :present, :integer
  end
end
