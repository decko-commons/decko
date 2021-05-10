# -*- encoding : utf-8 -*-

class AddCardVirtualsTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :card_virtuals if table_exists? :card_virtuals
    create_table :card_virtuals do |t|
      t.integer :left_id
      t.integer :right_id
      t.text :content, limit: 16_777_215
    end

    add_index :card_virtuals, :right_id, name: "left_id_index"
    add_index :card_virtuals, :left_id, name: "right_id_index"
  end

  def down
    drop_table :card_virtuals
  end
end
