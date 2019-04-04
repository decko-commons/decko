include_set Abstract::CodeFile

def source_files
  %w[decko_mod decko_editor decko_layout decko_navbox decko_upload
     decko_filter decko_slot decko_modal decko_overlay decko_recaptcha
     decko_slotter decko_bridge decko_nest_editor decko_nest_editor_rules
     decko_nest_editor_options decko_nest_editor_name decko_components decko].map do |n|
    "#{n}.js.coffee"
  end
end
