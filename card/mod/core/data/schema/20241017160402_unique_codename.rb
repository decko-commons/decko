# -*- encoding : utf-8 -*-

class UniqueCodename < Cardio::Migration::Schema
  def up
    remove_index :cards, name: "cards_codename_index"
    add_index :cards, :codename, name: "cards_codename_index", unique: true
  end

  def down
    remove_index :cards, name: "cards_codename_index"
    add_index :cards, :codename, name: "cards_codename_index"
  end
end
