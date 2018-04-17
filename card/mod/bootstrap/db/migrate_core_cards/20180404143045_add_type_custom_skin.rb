# -*- encoding : utf-8 -*-

require_relative "lib/skin"

class AddTypeCustomSkin < Card::Migration::Core
  def up
    ensure_card "Customized skin",
                type_id: Card::CardtypeID,
                codename: "customized_skin"
    ensure_card "*stylesheets", codename: "stylesheets"
    ensure_card "*bootswatch", codename: "bootswatch"
    ensure_card "*variables", codename: "variables"

    Skin.themes.each do |theme_name|
      skin = Skin.new(theme_name)
      ensure_card skin.skin_name, codename: skin.skin_codename
    end

    # remove deprecated bootswatch skin
    Card.fetch("readable skin+image")&.update_column :codename, nil
    delete_code_card "readable skin"
  end
end
