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
# Cards of type "customized bootswatch skin" have the same structure but make the
# variables and stylesheets part editable.
#
# Bootswatch theme cards are "asset inputters," meaning they generate a
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

include_set Abstract::AssetInputter, input_format: :css, input_view: :compressed
include_set Abstract::Scss
include_set Abstract::SkinBox

card_accessor :colors, type: :scss
card_accessor :variables, type: :scss
card_accessor :stylesheets, type: :skin
card_accessor :parent, type: :pointer

CONTENT_PARTS = %i[pre_variables variables post_variables stylesheets].freeze

PRE_VARIABLES_CARD_NAMES = %i[bootstrap_functions].freeze
POST_VARIABLES_CARD_NAMES = %i[bootstrap_core style_mods].freeze

def content
  CONTENT_PARTS.map do |n|
    send "#{n}_content"
  end.join "\n"
end

def item_names _args={}
  (PRE_VARIABLES_CARD_NAMES + variables_card_names +
    POST_VARIABLES_CARD_NAMES + stylesheets_card_names).compact.map do |n|
    Card.fetch_name(n)
  end.compact
end

def parent?
  parent_skin_card&.real?
end

def theme_name
  theme_codename.to_s.sub(/_skin$/, "")
end

def theme_card
  @theme_card ||= parent? ? parent_skin_card.theme_card : self
end

def theme_codename
  theme_card.codename
end

def scss_from_theme_file file
  path = ::File.join source_dir, "_#{file}.scss"
  path && ::File.exist?(path) ? ::File.read(path) : ""
end

def editable_item_cards
  [colors_card, variables_card, stylesheets_card]
end

def variables_card_names
  %i[colors variables].map { |s| Card.fetch_name name, s }
end

def stylesheets_card_names
  [Card.fetch_name(name, :stylesheets)]
end

def content_from_theme subfield
  theme_card&.scss_from_theme_file subfield
end

format :html do
  view :input do
    if parent?
      super()
    else
      "Content is stored in file and can't be edited."
    end
  end

  def edit_fields
    [[:colors, { title: "" }],
     [:variables, { title: "Variables" }],
     [:stylesheets, { title: "Styles" }]]
  end

  view :one_line_content do
    ""
  end
end

private

def parent_skin_card
  parent_card&.first_card
end

# needed to make the refresh_script_and_style method work with these cards
def source_files
  item_cards.map do |i_card|
    i_card.try(:source_files)
  end.flatten.compact
end

# needed to make the Assets.refresh method work with these cards
def existing_source_paths
  item_cards.map do |i_card|
    i_card.try(:existing_source_paths)
  end.flatten.compact
end

def pre_variables_content
  load_content(*PRE_VARIABLES_CARD_NAMES)
end

def variables_content
  combined_content :variables, variables_card_names
end

def post_variables_content
  load_content(*POST_VARIABLES_CARD_NAMES)
end

def stylesheets_content
  combined_content :bootswatch, stylesheets_card_names
end

def combined_content filename, cardnames
  [theme_card.scss_from_theme_file(filename), load_content(cardnames)].compact.join "\n"
end

def load_content *names
  cards = names.flatten.map do |n|
    Card.fetch(n)&.extended_item_cards
  end
  cards.flatten.compact.map(&:content).join "\n"
end

def source_dir
  @source_dir ||= ::File.expand_path(
    "#{mod_root :bootstrap}/vendor/bootswatch/dist/#{theme_name}", __FILE__
  )
end
