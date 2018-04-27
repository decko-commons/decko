# -*- encoding : utf-8 -*-

require_relative "lib/skin"

class AddBootswatchTheme < Card::Migration::Core
  def up
    ensure_card "style: right sidebar", codename: "style_right_sidebar"
    Card::Cache.reset_all

    ensure_card "Bootswatch theme", type_id: Card::CardtypeID,
                                    codename: "bootswatch_theme"
    update_card [:style, :right, :options],
                content: '{"type":["in", "Skin", "Bootswatch theme"],"sort":"name"}'
    Card::Cache.reset_all
    change_type_of_skins
  end

  def change_type_of_skins
    Skin.themes.each do |theme_name|
      skin_name = Skin.new(theme_name).skin_name
      puts "updating #{skin_name}"
      card = Card.fetch(skin_name)
      next puts "card not found" unless card
      card.update_attributes! type_id: Card::BootswatchThemeID
    end
  end
end
