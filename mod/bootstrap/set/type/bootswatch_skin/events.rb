
event :initialize_because_of_type_change, :prepare_to_store,
      on: :update, changed: :type do
  self.content = content
  initialize_theme
  if (items = old_skin_items)&.present?
    subfield :stylesheets, content: items
  end
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
  skin = Card.new type: :pointer, content: db_content_before_act
  skin.drop_item "bootstrap default skin"
  skin.item_names
end

def theme_error_type
  if theme_card.type_code != :bootswatch_skin
    :not_valid_theme
  elsif !Dir.exist? source_dir
    # puts method(:source_dir).source_location
    :cannot_source_theme
  end
end

def initialize_theme
  subfield :colors, type: :scss
  subfield :variables, type: :scss
end
