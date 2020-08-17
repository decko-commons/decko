class AddUniquePairIndeces < ActiveRecord::Migration[6.0]
  def change
    # TODO: uncomment following
    # add_index :cards, %i[left_id right_id], unique: true
    # add_index :card_virtuals, %i[left_id right_id], unique: true

    drop_table :users
  end
end
