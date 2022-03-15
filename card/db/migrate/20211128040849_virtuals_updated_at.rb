# -*- encoding : utf-8 -*-

class VirtualsUpdatedAt < ActiveRecord::Migration[6.0]
  def up
    add_column :card_virtuals, :updated_at, :datetime
  end

  def down
    remove_column :card_virtuals, :updated_at
  end
end
