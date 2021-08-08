include_set Abstract::CodeFile
basket[:style_libraries] << :style_datepicker

def source_files
  %w[lib/stylesheets/tempusdominus.scss
     vendor/tempusdominus/src/sass/_tempusdominus-bootstrap-4.scss]
end

def source_dir
  ""
end
