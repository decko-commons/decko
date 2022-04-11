
event :initialize_because_of_type_change, :prepare_to_store,
      on: :update, changed: :type do
  self.content = content
  initialize_theme old_skin_items
end

event :copy_theme, :prepare_to_store, on: :create do
  initialize_theme
end

event :validate_theme_template, :validate, on: :create do
  return unless (tname = theme_name) && (etype = theme_error_type)

  errors.add :abort, t("bootstrap_#{etype}", theme_name: tname)
end

private

def old_skin_items
  skin = Card.new(type: :pointer, content: db_content_before_act)
  skin.drop_item "bootstrap default skin"
  skin.item_names
end

def theme_error_type
  if Card.fetch_type_id(theme_card_name) != Card::BootswatchSkinID
    :not_valid_theme
  elsif !Dir.exist? source_dir
    # puts method(:source_dir).source_location
    :cannot_source_theme
  end
end

def initialize_theme style_item_names=nil
  subfield :colors, type: :scss
  subfield :variables, type: :scss
  # add_stylesheets_subfield style_item_names
end

def add_stylesheets_subfield style_items=nil
  opts = { type_id: Card::SkinID }
  if theme_name
    theme_style = add_bootswatch_subfield
    opts[:content] = "[[#{theme_style.name}]]"
  end
  if style_items
    opts[:content] = [opts[:content], style_items].flatten.compact.to_pointer_content
  end

  subfield :stylesheets, opts
end

def add_bootswatch_subfield
  subfield :bootswatch, type: :scss, content: content_from_theme(:bootswatch)
end