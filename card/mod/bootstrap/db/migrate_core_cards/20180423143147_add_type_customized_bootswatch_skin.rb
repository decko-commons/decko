# -*- encoding : utf-8 -*-

require_relative "lib/skin"

class AddTypeCustomizedBootswatchSkin < Card::Migration::Core
  def up
    rename_customized_bootswatch_skin
    ensure_card "*stylesheets", codename: "stylesheets"
    ensure_card "*bootswatch", codename: "bootswatch"
    ensure_card "*variables", codename: "variables"
    ensure_card "*colors", codename: "colors"

    Skin.themes.each do |theme_name|
      skin = Skin.new(theme_name)
      ensure_card skin.skin_name, codename: skin.skin_codename
    end

    remove_deprecated_bootswatch_skins
  end

  def rename_customized_bootswatch_skin
    ensure_card :customized_bootswatch_skin,
                name: "Customized bootswatch skin",
                type_id: Card::CardtypeID,
                codename: "customized_bootswatch_skin"
  end

  def remove_deprecated_bootswatch_skins
    Card.fetch("readable skin+image")&.update_column :codename, nil
    delete_code_card "readable skin"
    Card.fetch("paper skin+image")&.update_column :codename, nil
    delete_code_card "paper skin"
  end
end
