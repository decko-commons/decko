# -*- encoding : utf-8 -*-

class AddModType < Cardio::Migration::Core
  def up
    add_cardtypes
    Card::Cache.reset_all
  end

  def add_cardtypes
    ensure_code_card name: "Remote manifest group", type_id: Card::CardtypeID
    ensure_code_card name: "Mod", type_id: Card::CardtypeID
  end
end
