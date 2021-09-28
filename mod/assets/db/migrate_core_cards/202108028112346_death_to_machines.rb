# -*- encoding : utf-8 -*-

class DeathToMachines < Cardio::Migration::Core
  def up
    ["simple skin",
     "themeless bootstrap skin",
     "style: traditional",
     "style: common",
     "style: glyphicons"].each do |old_skin|
      delete_card old_skin
    end

    ensure_code_card "*asset input"
    ensure_code_card "*asset output"

    Card.search right: { codename: "machine_cache" } do |card|
      if card[0..1]
        # card[0..1].delete
      end
    end

    Card[:all, :style].item_cards.each do |card|
      next unless card.left&.type_id == Card::ModID && card.right&.codename == :style
      Card[:all, :style].drop_item! card
     end

    Card.search type_id: ["in", Card::ModScriptAssetsID, Card::ModStyleAssetsID] do |card|
      card.update type_id: Card::ListID
    end

    Card.search right: { codename: "machine_output" } do |card|
      next unless card.codename.present?
      card.update_column :codename, ""
    end

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

end
