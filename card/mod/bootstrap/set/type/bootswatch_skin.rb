include_set Abstract::BootswatchTheme

# override to customize the theme or to make it customizable
# @return [Card, String, Array<Card, String>] strings must be valid (s)css; cards
#         must be of type (S)CSS
def variables_content
  scss_from_theme_file :variables
end

# override to customize the theme or to make it customizable
# @return [Card, String, Array<Card,String>] strings must be valid (s)css; cards
#         must be of type (S)CSS
def stylesheets_content
  scss_from_theme_file(:bootswatch)
end
