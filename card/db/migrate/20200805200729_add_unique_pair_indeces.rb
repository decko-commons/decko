class AddUniquePairIndeces < ActiveRecord::Migration[6.0]
  def change
    stash_duplicate_cards
    delete_duplicate_virtuals
    add_index :cards, %i[left_id right_id], unique: true
    add_index :card_virtuals, %i[left_id right_id], unique: true

    drop_table :users
  end

  private

  def stash_duplicate_cards
    duplicates :cards do |id, left_id|
      stash_card id, (-100000 - left_id)
    end
  end

  def delete_duplicate_virtuals
    duplicates :card_virtuals do |id, _left_id|
      connection.execute "delete from card_virtuals where id = #{id}"
    end
  end

  def stash_card id, fake_id
    connection.execute(
      "UPDATE cards set left_id = #{fake_id}, trash = true where id = #{id}"
    )
  end

  def duplicates table
    sql = "SELECT distinct a.id from #{table} a join #{table} b " \
          "ON a.left_id = b.left_id AND a.right_id = b.right_id " \
          "AND a.id < b.id"
    connection.select_all(sql).each { |row| yield row["id"].to_i, row["left_id"].to_i }
  end

  def connection
    ActiveRecord::Base.connection
  end
end
