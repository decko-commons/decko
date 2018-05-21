# -*- encoding : utf-8 -*-

class AddJsonType < Card::Migration::Core
  def up
    ensure_card "json", codename: "json", type_id: Card::CardtypeID
    update_card :ace, type_id: Card::JsonID
    update_card :prose_mirror, type_id: Card::JsonID
    update_card :tiny_mce, type_id: Card::JsonID
  end
end
