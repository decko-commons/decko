# -*- encoding : utf-8 -*-

class AddPointerCards < Card::Migration
  def up
    ensure_card name: "Manifest group",
                type_id: Card::CardtypeID,
                codename: "manifest_group"
  end
end
