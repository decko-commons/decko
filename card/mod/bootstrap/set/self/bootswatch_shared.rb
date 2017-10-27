include_set Abstract::BootstrapCodeFile

def load_stylesheets
  add_stylesheet "font-awesome", type: :css
  add_stylesheet "material-icons", type: :css
  #add_bs_stylesheet "functions"
  #add_bs_stylesheet "variables"
  add_bs_subdir "mixins"
  %w[ print reboot type images code grid tables forms buttons transitions dropdown
      button-group input-group custom-forms nav navbar card breadcrumb pagination badge
      jumbotron alert progress media list-group close modal tooltip popover carousel
    ].each do |name|
      add_bs_stylesheet name
    end
  add_bs_subdir "utilities"
  add_stylesheet_file "vendor/select2/dist/css/select2.min.css"
  add_stylesheet_file "lib/stylesheets/style_select2_bootstrap.scss"
end

