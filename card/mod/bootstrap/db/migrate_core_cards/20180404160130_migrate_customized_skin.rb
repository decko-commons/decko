# -*- encoding : utf-8 -*-

class MigrateCustomizedSkin < Card::Migration::Core
  NEW_SKIN = "customized bootstrap skin"
  OLD_SKIN = :customizable_bootstrap_skin

  def up
    ensure_card "*stylesheets", codename: "stylesheets"
    ensure_card "*colors", codename: "colors"
    Card::Cache.reset_all

    migrate_customizable_bootstrap_skin
    delete_code_card OLD_SKIN

    Card.reset_all_machines
  end

  def migrate_customizable_bootstrap_skin
    referers = Card.search refers_to: { codename: OLD_SKIN.to_s }
    return unless referers.present?
    replace_old_skin referers
    build_new_skin
  end

  def replace_old_skin referers
    referers.each do |ref|
      new_content =
        ref.content.gsub("[cC]ustomizable[ _][bB]ootstrap[ _][sS]kin", NEW_SKIN)
      ref.update_attributes! content: new_content
    end
  end

  def build_new_skin
    ensure_card NEW_SKIN, type_id: Card::CustomizedSkinID

    variables =
      %w[colors components spacing cards fonts more].map do |name|
        Card.fetch(OLD_SKIN, "custom theme", name)&.content
      end.compact
    ensure_card [NEW_SKIN, :variables], type_id: Card::ScssID,
                content: variables.join("\n\n")

    custom_style =
      Card.fetch(OLD_SKIN, "custom theme", "style")&.content || ""
    ensure_card "customized bootstrap style", type_id: Card::ScssID, content: custom_style
    update_card [NEW_SKIN, :stylesheets],
                content: "[[customized bootstrap style]]"

  end
end
