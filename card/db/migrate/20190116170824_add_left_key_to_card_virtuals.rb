# -*- encoding : utf-8 -*-

class AddLeftKeyToCardVirtuals < ActiveRecord::Migration[4.2]
  def up
    add_column :card_virtuals, :left_key, :string
  end

  def down
    remove_column :card_virtuals, :left_key
  end
end
