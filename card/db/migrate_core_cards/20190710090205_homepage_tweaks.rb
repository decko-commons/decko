# -*- encoding : utf-8 -*-

class HomepageTweaks < Card::Migration::Core
  def up
    merge_cards ["*getting started", "*main menu", "*getting started+links"]
    update_card :wagn_bot, name: "Decko Bot"
    delete_code_card :customized_skin
    delete_code_card :bootswatch_theme
    update_card :basic, name: "Text"
  end
end
