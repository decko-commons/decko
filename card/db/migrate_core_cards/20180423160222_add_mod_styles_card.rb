# -*- encoding : utf-8 -*-

class AddModStylesCard < Card::Migration::Core
  def up
    ensure_card "style: mods", codename: "style_mods",
                               type_id: Card::PointerID
    ensure_card "script: libraries",
                codename: "script_libraries",
                type_id: Card::PointerID
    Card.fetch(:all, :script)&.insert_item! 0, "script: libraries"
    Card::Cache.reset_all
  end
end
