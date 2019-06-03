include_set Abstract::RolesDropdown

def ok_to_read
  true
end

def ok_to_update
  left_id == Auth.current_id
end

def ok_to_create
  left_id == Auth.current_id
end

def ensure_roles
  self.content = Auth.current_roles.to_pointer_content if content.blank?
end

event :validate_role_enabling, :validate, on: :save do
  illegal_roles = item_names - Auth.current_roles
  return if illegal_roles.empty?

  errors.add :content, "illegal roles: #{illegal_roles.to_sentence}" # LOCALIZE
end

event :clear_roles_cache, :prepare_to_store, before: :store_in_session do
  clear_roles
  Auth.update_always_cache Auth.as_id, nil
end

format :html do
  # permission change
  view :edit_inline, perms: :none, unknown: true, cache: :never, wrap: :slot do
    super()
  end

  def default_editor
    :checkbox
  end

  def edit_success
    { reload: true }
  end

  def hidden_form_tags _action, opts
    "#{super} #{hidden_tags(card: { type_id: SessionID } )}"
  end

  view :role_selection, cache: :never, unknown: true do
    card.ensure_roles
    wrap_with :div, class: "pointer-checkbox-list" do
      roles_dropdown roles_list
    end
  end

  def checkbox_input
    card.ensure_roles
    wrap_with :div, class: "pointer-checkbox-list" do
      roles_dropdown roles_list
    end
  end

  def list_input args={}
    items = items_for_input args[:item_list]
    extra_class = "pointer-list-ul"
    ul_classes = classy "pointer-list-editor", extra_class
    haml :list_input, items: items, ul_classes: ul_classes
  end

  def roles_list
    Auth.current_roles.map do |option_name|
      haml :role_checkbox, id: "pointer-checkbox-#{option_name.to_name.key}",
                           checked: card.item_names.include?(option_name),
                           option_name: option_name
    end
  end
end
