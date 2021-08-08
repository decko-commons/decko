# -*- encoding : utf-8 -*-

class AddModScriptAssetsType < Cardio::Migration::Core
  def up
    add_cardtypes
    delete_script_cards
    card = Card[:all, :script]
    ["script: jquery", "script: decko", "script: libraries",
     "script: editors", "script: mods"].each do |name|
      card.drop_item name
    end
    puts card.item_names
    card.save!
  end

  def add_cardtypes
    ensure_code_card name: "Mod script assets", type_code: :cardtype
    ensure_code_card name: "Local script folder group", type_code: :cardtype
    ensure_code_card name: "Local script manifest group", type_code: :cardtype
  end

  def delete_script_cards
    delete_code_card :script_decko
    delete_code_card :script_editors
    delete_code_card :script_pointer_config
    delete_code_card :script_jquery
    delete_code_card :script_mods
    delete_code_card :script_rules
  end
end
