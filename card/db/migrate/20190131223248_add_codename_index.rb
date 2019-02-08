class AddCodenameIndex < ActiveRecord::Migration[5.2]
  def up
    add_index :cards, [:codename], name: "cards_codename_index"
  end

  def down
    remove_index :cards, name: "cards_codename_index"
  end
end
