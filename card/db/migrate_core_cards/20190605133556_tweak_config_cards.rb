# -*- encoding : utf-8 -*-

class TweakConfigCards < Card::Migration::Core
  def up
    update :home, type_id: Card::PointerID, content: "[[#{Card[:home].content}]]"
    update :tiny_mce, type_id: Card::JsonID
    update "json", name: "Json"
    merge_cards "administrator+dashboard"
  end
end
