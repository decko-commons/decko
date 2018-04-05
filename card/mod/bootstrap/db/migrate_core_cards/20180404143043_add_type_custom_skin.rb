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
      Skin.new(theme_name).create_or_update
    end
  end
end
