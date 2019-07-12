# Bootswatch themes are free themes for bootstrap available at https://bootswatch.com/.
# For every bootswatch theme we have one card of card type "bootswatch skin".
# They all have codenames following the pattern "#{theme_name}_skin".
#
# The original bootswatch theme is build from two files, `_variables.scss` and
# `_bootswatch.scss`. The original bootstrap scss has to be put between those two.
# `_variables.scss` overrides bootstrap variables, `_bootswatch.scss` overrides
# bootstrap css (variables are defined with `!default` hence only the first appearance
# has an effect, for css the last appearance counts)
#
# The content of a bootswatch theme card consists of four parts:
#   * pre_variables: hard-coded theme independent stuff
#       and bootstrap functions to make them available in the variables part
#   * variables: the content from `_variables.scss`,
#   * post_variables: the bootstrap css and libraries like select2 and
#       bootstrap-colorpicker that depend on the theme
#   * stylesheets: the content from `_bootswatch.scss` and custom styles
#
# For the original bootswatch themes all those parts are hard-coded and the content
# is taken from files.
# The bootswatch theme content is taken directly from the files in the bootswatch
# submodule. For the rest we use code file cards.
# Cards of type "customized bootswatch skin" have the same structure but make the variables
# and stylesheets part editable.
#
# Bootswatch theme cards are machine cards for the following reason.
# Machine cards usually store all involved input cards of all nested levels in
# there +*machine_input pointer. All those input cards
# are processed separately and the result is joined to build the machine output.
# That's a problem for this card when it's used as input.
# A lot of the items depend on the variables scss and can't
# be processed independently. Therefore we return only self as item card and join
# the content of all the item cards in the content of the bootswatch theme card.
# But then this card has to forward updates of its items to the machine cards it provides
# input for.
# To do that it is a machine itself and stores the generated machine output as its
# content which will trigger the updates of other machines that use this card.

include_set Abstract::Machine
include_set Type::Scss
include_set Abstract::CodeFile
include_set Abstract::SkinBox

CONTENT_PARTS = %i[pre_variables variables post_variables stylesheets].freeze

PRE_VARIABLES_CARD_NAMES = %i[
  style_jquery_ui_smoothness
  bootstrap_functions
].freeze

POST_VARIABLES_CARD_NAMES = %i[
  bootstrap_core
  style_cards
  style_bootstrap_cards
  style_libraries
  style_mods
].freeze

# @return Array<Card::Name,String>
def variables_card_names
  []
end

# @return Array<Card::Name,String>
def stylesheets_card_names
  []
end

# reject cards that don't contribute directly to the content like skin or pointer cards
def engine_input
  extended_input_cards.select { |ca| ca.type_id.in? [ScssID, CssID] }
end

# Don't create "+*machine output" file card
# instead save the the output as the card's content is
def after_engine output
  Card::Auth.as_bot { update! db_content: output }
end

# needed to make the refresh_script_and_style method work with these cards
def source_files
  extended_input_cards.map do |i_card|
    i_card.try(:source_files)
  end.flatten.compact
end

# needed to make the refresh_script_and_style method work with these cards
def existing_source_paths
  extended_input_cards.map do |i_card|
    i_card.try(:existing_source_paths)
  end.flatten.compact
end

def extended_input_cards
  input_names.map do |n|
    Card.fetch(n).extended_item_cards
  end.flatten.compact
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
  load_content variables_card_names
end

def post_variables_content
  load_content(*POST_VARIABLES_CARD_NAMES)
end

def stylesheets_content
  load_content stylesheets_card_names
end

def input_names _args={}
  (PRE_VARIABLES_CARD_NAMES + variables_card_names +
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

def load_content *names
  cards = names.flatten.map { |n| Card.fetch(n)&.extended_item_cards }
  cards.flatten.compact.map(&:content).join "\n"
end

def scss_from_theme_file file
  return "" unless (path = ::File.join(source_dir, "_#{file}.scss")) &&
                   ::File.exist?(path)
  ::File.read path
end

def theme_name
  /^(.+)_skin$/.match(codename)&.capture(0) ||
    /^(.+)[ _][sS]kin/.match(name)&.capture(0)&.downcase
end

def source_dir
  @source_dir ||=
    ::File.expand_path "../../../vendor/bootswatch/dist/#{theme_name}", __FILE__
end
