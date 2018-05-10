include_set Abstract::CodeFile
Self::ScriptLibraries.add_item :script_jquery_helper

def source_files
  # jquery.ui.all must be after jquery.mobile to override dialog weirdness *
  # FIXME removed  jquerymobile.js. Doesn't work with the new jquery version
  # as fas as I'm aware of the only jquery widgets we use are
  # autocomplete, autosize and fileupload
  # autocomplete is intergrated in jquery-ui
  # don't know if iframe-transport is needed
  %w[jquery-ui.js
     jquery.autosize.js
     ../../vendor/jquery_file_upload/js/jquery.fileupload.js
     ../../vendor/jquery_file_upload/js/jquery.iframe-transport.js]
end
