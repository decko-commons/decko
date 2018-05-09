include_set Abstract::BootstrapCodeFile
Self::StyleLibraries.add_item :style_bootstrap_colorpicker

def load_stylesheets
  add_stylesheet_file "vendor/bootstrap-colorpicker/src/sass/_colorpicker.scss"
end
