
event :initialize_because_of_type_change, :prepare_to_store,
      on: :update, changed: :type do
  self.content = content
  initialize_theme
  if (items = old_skin_items)&.present?
    field :stylesheets, content: items
  end
end

event :copy_theme, :prepare_to_store, on: :create do
  initialize_theme
end

event :validate_theme_template, :validate, on: :create do
  return unless (theme = theme_card) && theme.type_code != :bootswatch_skin

  errors.add :abort, t(:bootstrap_not_valid_theme, theme_name: theme.name)
end

private

# I suspect we should remove this after Decko 1.0
def old_skin_items
  skin = Card.new type: :pointer, content: db_content_before_act
  skin.drop_item "bootstrap default skin"
  skin.item_names
end

def initialize_theme
  field :colors, type: :scss
  field :variables, type: :scss
end
