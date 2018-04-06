# -*- encoding : utf-8 -*-
#
require_relative "lib/skin"

class AddTypeCustomSkin < Card::Migration::Core
  def up
    ensure_card "Customized skin",
                type_id: Card::CardtypeID,
                codename: "customized_skin"
    ensure_card "*bootswatch", codename: "bootswatch"
    ensure_card "*variables", codename: "variables"


    Skin.themes.each do |theme_name|
      skin = Skin.new(theme_name)
      ensure_card skin.skin_name, codename: skin.skin_codename
    end

    delete_code_card "customizable bootstrap skin"

    # remove deprecated bootswatch skin
    update_card "readable skin", codename: nil
    update_card "readable skin+image", codename: nil, empty_ok: true
    delete_card "readable skin"
  end
end
