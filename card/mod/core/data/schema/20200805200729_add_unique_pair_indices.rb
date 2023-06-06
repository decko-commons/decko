class AddUniquePairIndices < Cardio::Migration::Schema
  def change
    stash_duplicate_cards
    delete_duplicate_virtuals
    add_index :cards, %i[left_id right_id], unique: true
    add_index :card_virtuals, %i[left_id right_id], unique: true

    drop_table :users
  end

  private

  def stash_duplicate_cards
    fake_id = -9000
    duplicates :cards do |id|
      stash_card id, fake_id
      fake_id = fake_id - 1
    end
  end

  def delete_duplicate_virtuals
    duplicates :card_virtuals do |id|
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
    connection.select_all(sql).each { |row| yield row["id"].to_i }
  end

  def connection
    ActiveRecord::Base.connection
  end
end
