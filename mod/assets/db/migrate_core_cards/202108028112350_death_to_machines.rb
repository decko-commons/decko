# -*- encoding : utf-8 -*-

class DeathToMachines < Cardio::Migration::Core
  def up
    delete_machine_output_cards
    delete_group_card
    delete_old_style_cards

    ensure_code_card "*asset input"
    ensure_code_card "*asset output"

    Card.search right: { codename: "machine_cache" } do |card|
      if card[0..1]
        # card[0..1].delete
      end
    end

    drop_all_style_items
    update_mod_asset_type_id

    Card::Cache.reset_all

    delete_deprecated_code_cards
  end

  private

  def update_mod_asset_type_id
    if Card::Codename.exists? "mod_script_assets"
      Card.search type_id: ["in", Card::ModScriptAssetsID, Card::ModStyleAssetsID] do |card|
        card.update! type_id: Card::ListID, skip: [:validate_asset_inputs, :update_asset_output_file]
      end
    end
  end

  def drop_all_style_items
    Card[:all, :style].item_cards.each do |card|
      next unless card.left&.type_id == Card::ModID && card.right&.codename == :style
      Card[:all, :style].drop_item! card
    end
  end

  def delete_deprecated_code_cards
    %i[machine_input
       machine_output
       machine_cache
       style_media
       style_prosemirror
       script_prosemirror
       script_prosemirror_config
       script_ace
       script_ace_config
       script_datepicker_config
       style_datepicker
       script_tinymce
       script_tinymce_config
       script_load_select2
       style_select2
       style_bootstrap_cards
       font_awesome
       material_icons
       style_bootstrap_colorpicker
       style_select2_bootstrap
       style_libraries
       script_html5shiv_printshiv
       smartmenu_css
       smartmenu_js
       mod_script_assets
       mod_style_assets
       style_bootstrap_compatible
       style_right_sidebar].each do |codename|
      delete_code_card codename
    end
  end

  def delete_machine_output_cards
    Card.search right: { codename: "machine_output" } do |card|
      next unless card.codename.present?
      card.update_column :codename, ""
      card.delete!
    end
  end

  def delete_old_style_cards
    ["simple skin",
     "themeless bootstrap skin",
     "style: traditional",
     "style: common",
     "style: glyphicons"].each do |old_skin|
      delete_card old_skin
    end
  end

  def delete_group_card
    Card.search type_id: ["in", Card::LocalScriptManifestGroupID, Card::LocalStyleManifestGroupID,
                          Card::LocalScriptFolderGroupID, Card::LocalStyleFolderGroupID] do |card|
      Card.search left_id: card.id do |field|
        field.update_column :codename, ""
        field.delete
      end
      card.update_column :codename, ""
      card.delete! skip: :asset_input_changed_on_delete
    end
  end
end
