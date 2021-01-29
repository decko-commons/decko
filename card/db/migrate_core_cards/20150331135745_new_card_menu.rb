# -*- encoding : utf-8 -*-

class NewCardMenu < Cardio::Migration::Core
  def up
    menu_js = Card[:script_card_menu]
    menu_js.update! type_id: Card::CoffeeScriptID
  end
end
