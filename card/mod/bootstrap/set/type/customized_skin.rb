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

def variable_card_names
  [:colors, :variables].map { |s| Card.fetch_name name, s }
end

def stylesheet_card_names
  [Card.fetch_name(name, :stylesheets)]
end

def variables_input
  [colors_card, variables_card]
end

def stylesheets_input
  stylesheets_card.extended_item_cards
end

def theme_card_name
  "#{@theme} skin"
end

def theme_codename
  "#{@theme}_skin".to_sym
end

event :validate_theme_template, :validate, on: :create do
  if (@theme = Env.params[:theme]).present?
    if Card.fetch_type_id(theme_card_name) != Card::SkinID
      errors.add :abort, "not a valid theme: #{@theme}"
    elsif !Dir.exist?(source_dir)
      errors.add :abort, "can't find source for theme \"#{@theme}\""
    end
  end
end

event :copy_theme, :prepare_to_store, on: :create do
  add_subfield :colors, type_id: ScssID
  add_variables_subfield
  add_stylesheets_subfield
end

def add_stylesheets_subfield
  opts = { type_id: SkinID }
  if @theme
    theme_style = add_bootswatch_subfield
    opts[:content] = "[[#{theme_style.name}]]"
  end

  add_subfield :stylesheets, opts
end

def add_variables_subfield
  theme_content = content_from_theme(:variables)
  default_content = Type::CustomizedSkin.read_bootstrap_variables
  add_subfield :variables,
               type_id: ScssID,
               content: "#{theme_content}\n\n\n#{default_content}"
end

def add_bootswatch_subfield
  add_subfield field_name, type_id: ScssID, content: content_from_theme(:bootswatch)
end

def theme_card
  @theme_card ||= @theme && Card[theme_codename]
end

def content_from_theme subfield
  theme_card&.send("#{subfield}_scss") || ""
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
