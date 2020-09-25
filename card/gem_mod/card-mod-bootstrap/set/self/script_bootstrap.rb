include_set Abstract::CodeFile
Self::ScriptLibraries.add_item :script_bootstrap

def source_dir
  ""
end

def source_files
  %w[vendor/bootstrap/dist/js/bootstrap.bundle.js
     lib/javascript/bootstrap_modal_decko.js
     vendor/bootstrap-colorpicker/dist/js/bootstrap-colorpicker.min.js]
end
