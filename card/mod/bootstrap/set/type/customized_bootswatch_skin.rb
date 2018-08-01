class << self
  def read_bootstrap_variables
    path =
      ::File.expand_path("../../../vendor/bootstrap/scss/_variables.scss", __FILE__)
    ::File.exist?(path) ? ::File.read(path) : ""
  end
end

include_set Abstract::BootswatchTheme

card_accessor :colors
card_accessor :variables
card_accessor :stylesheets

def top_level_item_cards
  cards = PRE_VARIABLES_CARD_NAMES.map { |n| Card[n] }
  cards += [colors_card, variables_card]
  cards += POST_VARIABLES_CARD_NAMES.map { |n| Card[n] }
  cards << stylesheets_card
  cards
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

def theme_card_name
  "#{theme_name} skin"
end

def theme_name
  Env.params[:theme].present? && Env.params[:theme]
end

def theme_codename
  theme_name && "#{theme_name}_skin".to_sym
end

event :validate_theme_template, :validate, on: :create do
  if theme_name
    if Card.fetch_type_id(theme_card_name) != Card::BootswatchSkinID
      errors.add :abort, tr(:not_valid_theme, theme_name: theme_name)
    elsif !Dir.exist?(source_dir)
      errors.add :abort, tr(:cant_find_source_theme, theme_name: theme_name)
    end
  end
end

event :initialize_because_of_type_change, :prepare_to_store,
      on: :update, changed: :type do
  initialize_theme old_skin_items
end

def old_skin_items
  skin = Card.new(type: :pointer, content: db_content_before_act)
  skin.drop_item "bootstrap default skin"
  skin.item_names
end

event :copy_theme, :prepare_to_store, on: :create do
  initialize_theme
end

def initialize_theme style_item_names=nil
  add_subfield :colors, type_id: ScssID
  add_variables_subfield
  add_stylesheets_subfield style_item_names
end

def add_stylesheets_subfield style_items=nil
  opts = { type_id: SkinID }
  if theme_name
    theme_style = add_bootswatch_subfield
    opts[:content] = "[[#{theme_style.name}]]"
  end
  if style_items
    opts[:content] = [opts[:content], style_items].flatten.compact.to_pointer_content
  end

  add_subfield :stylesheets, opts
end

def add_variables_subfield
  theme_content = content_from_theme(:variables)
  default_content = Type::CustomizedBootswatchSkin.read_bootstrap_variables
  add_subfield :variables,
               type_id: ScssID,
               content: "#{theme_content}\n\n\n#{default_content}"
end

def add_bootswatch_subfield
  add_subfield :bootswatch, type_id: ScssID, content: content_from_theme(:bootswatch)
end

def theme_card
  @theme_card ||= theme_codename ? Card[theme_codename] : nil
end

def content_from_theme subfield
  theme_card&.scss_from_theme_file subfield
end

format :html do
  def edit_fields
    [[:colors, { title: "" }],
     [:variables, { title: "Variables" }],
     [:stylesheets, { title: "Styles" }]]
  end

  view :closed_content do
    ""
  end
end
