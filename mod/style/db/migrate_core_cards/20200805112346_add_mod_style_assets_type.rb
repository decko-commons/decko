# -*- encoding : utf-8 -*-

class AddModStyleAssetsType < Cardio::Migration::Core
  def up
    add_cardtypes
    delete_style_cards
  end

  def add_cardtypes
    ensure_code_card name: "Mod style assets", type_id: Card::CardtypeID
    ensure_code_card name: "Local style folder group", type_id: Card::CardtypeID
    ensure_code_card name: "Local style manifest group", type_id: Card::CardtypeID
  end

  def delete_style_cards
    # delete_code_card :script_decko
  end
end
