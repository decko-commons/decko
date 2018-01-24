include_set Abstract::CodeFile

def source_files
  %w[decko_mod decko_editor decko_layout decko_navbox decko_upload
     decko_filter decko_slot decko_recaptcha
     decko_slotter decko].map do |n|
    "#{n}.js.coffee"
  end
end
