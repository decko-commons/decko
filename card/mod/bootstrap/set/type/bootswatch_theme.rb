# Usually machine cards store all involved input cards of all nested levels
# in there +*machine_input pointer.
# That's a problem for this card when it's used as input.
# A lot of the items depend on the variables scss and can't
# be processed independently. Therefore we return only self as item cards.
# But then this card has to forward updates of its items to the machine cards it provides
# input for.
# To do that it is a machine itself  and stores the generated machine output as its
# content which will trigger the updates of other machines that use this card.

include_set Abstract::Machine
include_set Type::Scss
include_set Abstract::CodeFile
include_set Abstract::SkinThumbnail

CONTENT_PARTS = %i[pre_variables variables post_variables stylesheets]

PRE_VARIABLES_CARD_NAMES = %i[
  style_jquery_ui_smoothness
  style_cards
  style_right_sidebar
  font_awesome
  material_icons
  bootstrap_functions
]

POST_VARIABLES_CARD_NAMES = %i[
  bootstrap_variables
  bootstrap_core
  style_bootstrap_cards
]

def engine_input
  # reject e.g. skin cards among the stylesheets cards
  extended_input_cards.select { |ca| ca.type_id.in? [ScssID, CssID] }
end

def after_engine output
  Card::Auth.as_bot { update_attributes! db_content: output }
end

# def machine_input
#   content
# end

def source_files
  extended_input_cards.map do |i_card|
    i_card.try(:source_files)
  end.flatten.compact
end

def extended_input_cards
  names = PRE_VARIABLES_CARD_NAMES + variable_card_names + POST_VARIABLES_CARD_NAMES
  cards = names.map { |n| Card.fetch n }
  cards += extended_stylesheets_cards
  cards.compact
end

# @return Array<Card::Name,String>
def variable_card_names
  []
end

# @return Array<Card::Name,String>
def stylesheets_card_names
  []
end

# all nested items of stylesheet cards
def extended_stylesheets_cards
  []
end

def content
  CONTENT_PARTS.map do |n|
    send "#{n}_content"
  end.join "\n"
end

def pre_variables_content
  load_content(*PRE_VARIABLES_CARD_NAMES)
end

def variables_content
  to_content variables_input
end

def post_variables_content
  load_content(*POST_VARIABLES_CARD_NAMES)
end

def stylesheets_content
  to_content stylesheets_input
end

def input_names _args={}
  (PRE_VARIABLES_CARD_NAMES + variable_card_names +
    POST_VARIABLES_CARD_NAMES + stylesheets_card_names).compact.map do |n|
    Card.fetch_name(n)
  end.compact
end

def item_names _args={}
  []
end

def item_cards _args={}
  [self]
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
      # inp.content
      inp.extended_item_cards.map(&:content).join "\n"
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
  /^(.+)_skin$/.match(codename)&.capture(0) ||
    /^(.+)[ _][sS]kin/.match(name).capture(0)&.downcase
end

def source_dir
  @source_dir ||=
    ::File.expand_path "../../../vendor/bootswatch/dist/#{theme_name}", __FILE__
end


format :html do
  view :thumbnail, template: :haml do
    voo.show! :customize_button, :thumbnail_image
  end
end
