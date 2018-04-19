include_set Type::Scss

CONTENT_PARTS = [:pre_variables, :variables, :post_variables, :stylesheets]

PRE_VARIABLES_CARD_NAMES = [
  :style_jquery_ui_smoothness,
  :style_cards,
  "style: right sidebar",
  :font_awesome,
  :material_icons,
  :bootstrap_functions
]

POST_VARIABLES_CARD_NAMES = [
  :bootstrap_core,
  :style_bootstrap_cards
]

# @return Array<Card::Name,String>
def variable_card_names
  []
end

# @return Array<Card::Name,String>
def stylesheets_card_names
  []
end

def content
  CONTENT_PARTS.map do |n|
    send "#{n}_content"
  end.join "\n"
end

def pre_variables_content
  load_content *PRE_VARIABLES_CARD_NAMES
end

def variables_content
  to_content variables_input
end

def post_variables_content
  load_content *POST_VARIABLES_CARD_NAMES
end

def stylesheets_content
  to_content stylesheets_input
end

def item_names _args={}
  (PRE_VARIABLES_CARD_NAMES + variable_card_names +
    POST_VARIABLES_CARD_NAMES + stylesheet_card_names).compact.map do |n|
    Card.fetch_name(n)
  end.compact
end

def item_cards _args={}
  item_names.map do |n|
    Card.fetch n
  end.compact
end

# @return [Card, String, Array<Card, String>] strings must be valid (s)css; cards
#         must be of type (S)CSS
def variables_input
  scss_from_theme_file :variables
end

# @return [Card, String, Array<Card,String>] strings must be valid (s)css; cards
#         must be of type (S)CSS
def stylesheets_input
  scss_from_theme_file :bootswatch
end

def to_content cards_or_strings
  inputs = Array.wrap(cards_or_strings).flatten
  inputs.map do |inp|
    if inp.is_a?(Card)
      inp.content
      # inp.extented_item_cards.map { |ca| ca.content }.join "\n"
    else
      inp
    end
  end.join "\n"
end

def load_content *names
  cards = names.map { |n| Card[n] }
  cards.compact.map(&:content).join "\n"
end

def scss_from_theme_file file
  return "" unless (path = ::File.join(source_dir, "_#{file}.scss")) &&
                   ::File.exist?(path)
  ::File.read path
end

def theme_name
  codename.match(/^(.+)_skin$/).capture(0)
end

def source_dir
  @source_dir ||=
    ::File.expand_path "../../../vendor/bootswatch/dist/#{theme_name}", __FILE__
end







