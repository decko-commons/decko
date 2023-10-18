# -*- encoding : utf-8 -*-

class AddLeftKeyToCardVirtuals < Cardio::Migration::Schema
  def up
    add_column :card_virtuals, :left_key, :string
  end

  def down
    remove_column :card_virtuals, :left_key
  end
end
