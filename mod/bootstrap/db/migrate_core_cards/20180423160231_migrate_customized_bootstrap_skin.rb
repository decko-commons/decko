# -*- encoding : utf-8 -*-

require_relative "lib/skin"

class Skin
  # def customized?
  #   skin_cards.any? do |name_parts|
  #     (card = Card.fetch(name_parts)) && !card.pristine?
  #   end
  # end
  #
  #
  # def migrate
  #   new_name = "#{skin_name} customized"
  #   Card.ensure new_name, type_id: Card::CustomizedBootswatchSkinID
  #   Card.ensure name: [new_name, :variables],
  #               type_id: Card::ScssID,
  #               content: Card.fetch(skin_name, "variables")&.content
  #   Card.ensure name: [new_name, :bootswatch],
  #               type_id: Card::ScssID,
  #               content: Card.fetch(skin_name, "style")&.content
  #   update_skin_references
  #   delete_deprecated_skin_cards
  # end
  #
  # def update_skin_references
  #   Card.search(refer_to: skin_name).each do |ref|
  #     new_content = ref.content.gsub(/#{theme_name}[ _]skin/i,
  #       "#{skin_name} customized")
  #     card.update! content: new_content
  #   end
  # end
end

class MigrateCustomizedBootstrapSkin < Cardio::Migration::Core
  NEW_SKIN = "customized bootstrap skin".freeze
  OLD_SKIN = :customizable_bootstrap_skin

  def up
    Card.ensure name: "*stylesheets", codename: "stylesheets"
    Card.ensure name: "*colors", codename: "colors"
    Card.ensure name: "style: mods", codename: "style_mods", type_id: Card::PointerID
    Card.ensure name: "style: right sidebar", codename: "style_right_sidebar"
    Card::Cache.reset_all

    migrate_customizable_bootstrap_skin

    # Card::Machine.reset_all
  end

  def migrate_customizable_bootstrap_skin
    referers = Card.search refer_to: { codename: OLD_SKIN.to_s }
    return unless referers.present?

    replace_old_skin referers
    build_new_skin
    delete_code_card OLD_SKIN
  end

  def replace_old_skin referers
    referers.each do |ref|
      new_content = ref.content.gsub(/customizable[ _]bootstrap[ _]skin/i, NEW_SKIN)
      ref.update! content: new_content
    end
  end

  def build_new_skin
    Card.ensure name: NEW_SKIN, type_id: Card::CustomizedBootswatchSkinID

    variables =
      %w[colors components spacing cards fonts more].map do |name|
        Card.fetch(OLD_SKIN, "custom theme", name)&.content
      end.compact
    Card.ensure name: [NEW_SKIN, :variables], type: :scss, content: variables.join("\n\n")

    custom_style =
      Card.fetch(OLD_SKIN, "custom theme", "style")&.content || ""
    Card.ensure name: "customized bootstrap style", type: :scss, content: custom_style
    update_card! [NEW_SKIN, :stylesheets],
                 content: "[[customized bootstrap style]]"
  end
end
