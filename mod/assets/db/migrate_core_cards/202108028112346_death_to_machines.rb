# -*- encoding : utf-8 -*-

class DeathToMachines < Cardio::Migration::Core
  def up
    ensure_code_card "*asset input"
    ensure_code_card "*asset output"

    Card.search right: { codename: "machine_cache" } do |card|
      if card[0..1]
        # card[0..1].delete
      end
    end

    Card[:all, :style].item_cards.each do |card|
      next unless card.type_id == Card::ModStyleAssetsID
      Card[:all, :style].drop_item! card
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
       style_mods
       smartmenu_css
       smartmenu_js].each do |codename|
      delete_code_card codename
    end

  end

end
