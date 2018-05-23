# -*- encoding : utf-8 -*-

require_relative "lib/skin"

class AddTypeBootswatchSkin < Card::Migration::Core
  STYLE_INPUT_SEARCH = <<-JSON.strip_heredoc
    {"type": {"codename": ["in", "skin", "bootswatch_skin", "customized_bootswatch_skin"]}, "sort": "name"}
  JSON
  def up
    ensure_card "style: mods", codename: "style_mods",
                               type_id: Card::PointerID
    ensure_card "style: right sidebar", codename: "style_right_sidebar"
    Card::Cache.reset_all

    ensure_card "Bootswatch skin", type_id: Card::CardtypeID,
                                   codename: "bootswatch_skin"
    update_card %i[style right options], content: STYLE_INPUT_SEARCH
    Card::Cache.reset_all
    change_type_of_skins
  end

  def change_type_of_skins
    Skin.themes.each do |theme_name|
      skin_name = Skin.new(theme_name).skin_name
      puts "updating #{skin_name}"
      card = Card.fetch(skin_name)
      next puts "card not found" unless card
      card.update_attributes! type_id: Card::BootswatchSkinID
    end
  end
end
