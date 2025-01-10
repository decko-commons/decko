# -*- encoding : utf-8 -*-

class UniqueCodename < Cardio::Migration::Schema
  def up
    remove_blank_codenames
    remove_index :cards, name: "cards_codename_index"
    add_index :cards, :codename, name: "cards_codename_index", unique: true
  end

  def down
    remove_index :cards, name: "cards_codename_index"
    add_index :cards, :codename, name: "cards_codename_index"
  end

  private

  def remove_blank_codenames
    connection.execute "UPDATE cards SET codename = null where codename = ''"
  end

  def connection
    ActiveRecord::Base.lease_connection
  end
end
