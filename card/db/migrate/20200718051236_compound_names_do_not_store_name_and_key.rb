class CompoundNamesDoNotStoreNameAndKey < ActiveRecord::Migration[6.0]
  def change
    change_column_null :cards, :name, true
    change_column_null :cards, :key, true
    Card.where.not(left_id: nil).in_batches.update_all name: nil, key: nil
  end
end
