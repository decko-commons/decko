event :create_alias_upon_rename, :finalize,
      on: :update, changed: :name, trigger: :required do
  add_subcard name_before_act, type_code: :alias, content: name
end

def alias?
  false
end

format :html do
  def edit_name_buttons
    output [auto_alias_checkbox, super].compact
  end

  def auto_alias_checkbox
    haml :auto_alias_checkbox if card.simple?
  end
end