# -*- encoding : utf-8 -*-

require_relative "lib/skin"

class UpdateBootswatchThemesTo4Beta < Cardio::Migration::Core
  def up
    remove_old_stuff
    update_bootstrap_cards
    add_icon_cards

    puts "Updating bootstrap themes ..."
    Skin.themes.each do |theme_name|
      puts theme_name
      Skin.new(theme_name).create_or_update
    end
    update_bootstrap_default
    Card::Cache.reset_all
  end

  def update_bootstrap_cards
    %w[breakpoints functions variables core mixins].each do |n|
      ensure_scss "bootstrap: #{n}", codename: "bootstrap_#{n}"
      delete_code_card "style: bootstrap #{n}"
    end
    if Card::Codename.exist? :bootstrap_cards
      update_card! :bootstrap_cards,
                   name: "style: bootstrap cards",
                   codename: "style_bootstrap_cards"
    end
  end

  def remove_old_stuff
    delete_code_card :bootswatch_shared
    delete_card "bootswatch theme+*right+*structure"
    Card[:all, :style].drop_item! "style: select2"
    Card[:all, :style].drop_item! "style: select2 bootstrap"
    delete_code_card :bootswatch_shared
  end

  def update_bootstrap_default
    Card.ensure name: "bootstrap default skin+bootswatch theme",
                type_id: Card::ScssID,
                content: "{{bootstrap: functions}}" \
                         "{{bootstrap: variables}}" \
                         "{{bootstrap: core}}"
  end

  def add_icon_cards
    %w[font_awesome material_icons].each do |name|
      ensure_css name.tr("_", " "), codename: name
      Card["themeless bootstrap skin"].add_item! name.tr("_", " ")
    end
  end
end
