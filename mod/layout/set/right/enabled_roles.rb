include_set Abstract::AccountDropdown

assign_type :session

def ok_to_read?
  true
end

def ok_to_update?
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
  Auth.current.clear_roles
  Auth.update_always_cache nil
end

format :html do
  # permission change compared to super
  view :edit_inline, perms: :none, unknown: true, cache: :never, wrap: :slot do
    super()
  end

  def input_type
    :checkbox
  end

  def edit_success
    { reload: true }
  end

  def hidden_form_tags _action, opts
    "#{super} #{hidden_tags card: { type_id: SessionID }}"
  end

  def checkbox_input
    card.ensure_roles
    voo.show! :role_item_checkbox
    wrap_with :div, class: "pointer-checkbox-list" do
      account_dropdown
    end
  end

  def role_item_checkbox role_name
    haml :role_checkbox, id: "pointer-checkbox-#{role_name.to_name.key}",
                         checked: card.item_names.include?(role_name),
                         option_name: role_name
  end

  def account_dropdown_role_items
    Auth.current_roles.map { |role| role_item_checkbox role }
  end
end
