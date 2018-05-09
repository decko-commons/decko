include_set Abstract::CodeFile
Self::ScriptLibraries.add_item :script_jquery_helper

def source_files
  # jquery.ui.all must be after jquery.mobile to override dialog weirdness *
  # FIXME removed  jquerymobile.js. Doesn't work with the new jquery version
  # as fas as I'm aware of we use the only jquery widgets we use are
  # autocomplete and autosize
  # autocomplete is intergrated in jquery-ui
  %w[jquery-ui.js jquery.autosize.js]
end
