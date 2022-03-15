# -*- encoding : utf-8 -*-

class DeathToMachines < Cardio::Migration::Core
  DEPRECATED_CODE_NAMES = %i[
    machine_input machine_output machine_cache
    style_media
    style_prosemirror script_prosemirror script_prosemirror_config
    script_ace script_ace_config
    script_datepicker_config style_datepicker
    script_tinymce script_tinymce_config
    script_load_select2 style_select2 script_select2
    style_bootstrap_cards
    font_awesome
    material_icons
    style_bootstrap_colorpicker
    style_select2_bootstrap
    style_libraries
    script_html5shiv_printshiv
    smartmenu_css smartmenu_js
    mod_script_assets mod_style_assets
    style_bootstrap_compatible
    style_right_sidebar
    style_bootstrap_mixins
    style_bootstrap_breakpoints
    script_bootstrap
    script_datepicker
    script_jquery_helper style_jquery_ui_smoothness
    style_cards
  ].freeze

  DEPRECATED_CARD_NAMES = [
    "simple skin",
    "themeless bootstrap skin",
    "style: traditional", "style: common", "style: glyphicons",
    "classic bootstrap skin+*colors", "classic bootstrap skin+*variables",
    "style: classic cards"
  ].freeze

  def up
    delete_machine_cards :machine_output
    delete_machine_cards :machine_input
    delete_machine_cards :machine_cache
    delete_group_card
    delete_old_style_cards

    ensure_code_card "*asset input"
    ensure_code_card "*asset output"

    drop_all_style_items
    update_mod_asset_type_id

    Card::Cache.reset_all

    delete_deprecated_code_cards
  end

  private

  def update_mod_asset_type_id
    return unless Card::Codename.exists? "mod_script_assets"

    Card.search type_id: ["in", Card::ModScriptAssetsID, Card::ModStyleAssetsID] do |card|
      card.update! type_id: Card::ListID,
                   skip: %i[validate_asset_inputs update_asset_output_file]
    end
  end

  def drop_all_style_items
    Card[:all, :style].item_cards.each do |card|
      next unless card.left&.type_id == Card::ModID && card.right&.codename == :style
      Card[:all, :style].drop_item! card
    end
  end

  def delete_deprecated_code_cards
    DEPRECATED_CODE_NAMES.each do |codename|
      delete_code_card codename
    end

    %w[cerulean cosmo cyborg darkly flatly journal lumen
       paper readable sandstone simplex
       slate spacelab superhero united yeti bootstrap_default].each do |theme|
      delete_code_card "theme_#{theme}"
    end
  end

  def delete_machine_cards codename
    Card.search right: codename do |card|
      card.update_column :codename, ""
      card.delete!
    end
  end

  def delete_old_style_cards
    DEPRECATED_CARD_NAMES.each do |doomed|
      delete_card doomed
    end
  end

  def delete_group_card
    Card.search type_id: ["in",
                          Card::LocalScriptManifestGroupID,
                          Card::LocalStyleManifestGroupID,
                          Card::LocalScriptFolderGroupID,
                          Card::LocalStyleFolderGroupID] do |card|
      Card.search left_id: card.id do |field|
        field.update_column :codename, ""
        field.delete
      end
      card.update_column :codename, ""
      card.delete! skip: :asset_input_changed_on_delete
    end
  end
end
