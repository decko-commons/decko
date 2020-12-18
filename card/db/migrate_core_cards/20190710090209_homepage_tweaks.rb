# -*- encoding : utf-8 -*-

class HomepageTweaks < Cardio::Migration::Core
  def up
    merge_cards ["*getting started", "*main menu", "*getting started links"]
    update_card! :wagn_bot, name: "Decko Bot", update_referers: true
    delete_code_card :customized_skin
    delete_code_card :bootswatch_theme
    unless Card.fetch_name(:basic) == "RichText"
      update_card! :basic, name: "RichText", update_referers: true
    end
    unless Card.fetch_name(:json) == "JSON"
      update_card! :json, name: "JSON", update_referers: true
    end
    delete_card "*getting started+links"
  end
end
