include_set Abstract::CodeFile
Self::ScriptLibraries.add_item :script_bootstrap

def source_dir
  ""
end

def source_files
  %w[vendor/bootstrap/assets/js/vendor/popper.min.js
     vendor/bootstrap/dist/js/bootstrap.min.js
     lib/javascript/bootstrap_modal_wagn.js
     vendor/bootstrap-colorpicker/dist/js/bootstrap-colorpicker.min.js]
end
