# -*- encoding : utf-8 -*-

class AddTrashIndex < Cardio::Migration::Schema
  def up
    add_index :cards, :trash, name: "cards_trash_index"
  end

  def down
    remove_index :cards, name: "cards_trash_index"
  end
end
