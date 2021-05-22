# -*- encoding : utf-8 -*-

class AddModAssetsType < Cardio::Migration::Core
  def up
    ensure_code_card name: "Mod script assets", type_id: Card::CardtypeID
    ensure_code_card name: "Local folder group", type_id: Card::CardtypeID
    ensure_code_card name: "Local manifest group", type_id: Card::CardtypeID
    ensure_code_card name: "Remote manifest group", type_id: Card::CardtypeID
    delete_code_card :script_decko
    delete_code_card :script_editors
    delete_code_card :script_pointer_config
    delete_code_card :script_jquery
    delete_code_card :script_mods
    card = Card[:all, :script]
    ["script: jquery", "script: decko", "script: libraries", "script: editors", "script: mods"].each do |name|
      card.drop_item name
    end
    puts card.item_names
    card.save!
  end
end
