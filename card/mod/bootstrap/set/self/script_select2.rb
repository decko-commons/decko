include_set Abstract::CodeFile
Self::ScriptLibraries.add_item :script_select2

def source_files
  # full version of select2 is needed to support containerCssClass config option
  # which we need for select2_bootstrap to work properly
  "vendor/select2/dist/js/select2.full.min.js"
end

def source_dir
  ""
end
