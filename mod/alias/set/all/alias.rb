# triggerable event to auto-add an alias upon renaming a card
event :create_alias_upon_rename, :finalize,
      on: :update, changed: :name, trigger: :required do
  add_subcard name_before_act, type_code: :alias, content: name
end

# actual aliases override this in narrower sets.
def alias?
  false
end

format :html do
  # adds checkbox to rename form
  def edit_name_buttons
    output [auto_alias_checkbox, super].compact
  end

  def auto_alias_checkbox
    haml :auto_alias_checkbox if card.simple?
  end
end
