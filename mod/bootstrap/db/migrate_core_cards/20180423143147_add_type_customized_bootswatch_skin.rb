# -*- encoding : utf-8 -*-

require_relative "lib/skin"

class AddTypeCustomizedBootswatchSkin < Cardio::Migration::Core
  def up
    rename_customized_bootswatch_skin
    Card.ensure name: "*stylesheets", codename: "stylesheets"
    Card.ensure name: "*bootswatch", codename: "bootswatch"
    Card.ensure name: "*variables", codename: "variables"
    Card.ensure name: "*colors", codename: "colors"

    Skin.themes.each do |theme_name|
      skin = Skin.new(theme_name)
      Card.ensure name: skin.skin_name, codename: skin.skin_codename
    end

    remove_deprecated_bootswatch_skins
  end

  def rename_customized_bootswatch_skin
    Card.ensure name: "Customized bootswatch skin",
                codename: "customized_bootswatch_skin",
                type: :cardtype
  end

  def remove_deprecated_bootswatch_skins
    Card.fetch("readable skin+image")&.update_column :codename, nil
    delete_code_card "readable skin"
    Card.fetch("paper skin+image")&.update_column :codename, nil
    delete_code_card "paper skin"
  end
end
