# -*- encoding : utf-8 -*-

class ReorganizeScripts2 < Card::Migration::Core
  def up
    delete_code_card :script_card_menu
    if Card::Codename[:script_slot]
      update_card :script_slot, name: "script: decko",
                                codename: "script_decko",
                                update_referers: true
    end
    if (card = Card[:all, :script])
      card.drop_item "script: card menu"
      card.drop_item "script: select2"
      card.drop_item "script: load select2"
      card.save!
    end
    Card.reset_all_machines
  end
end
