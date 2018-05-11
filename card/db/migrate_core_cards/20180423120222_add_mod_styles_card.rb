# -*- encoding : utf-8 -*-

class AddModStylesCard < Card::Migration::Core
  def up
    ensure_card "style: mods", codename: "style_mods",
                               type_id: Card::PointerID
    ensure_card "style: libraries", codename: "style_libraries",
                                    type_id: Card::PointerID
    ensure_card "script: libraries",
                codename: "script_libraries",
                type_id: Card::PointerID
    if (card = Card.fetch(:all, :script))
      card.insert_item 4, "script: libraries"
      card.drop_item "script: select2"
      card.drop_item "script: load select2"
      card.save!
    end
    Card::Cache.reset_all
  end
end
