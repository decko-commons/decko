# -*- encoding : utf-8 -*-

class DeathToMachines < Cardio::Migration::Core
  def up
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
       script_tinymce_config  ].each do |codename|
      delete_code_card codename
    end

    ensure_code_card "asset_input"
    ensure_code_card "asset_output"
  end

end
