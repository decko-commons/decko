def disabled?
  Auth.current&.fetch(trait: :disabled_roles)&.item_ids&.include? id
end

format :html do
  view :link_with_checkbox, cache: :never do
    role_checkbox
  end

  def role_checkbox
    name = card.disabled? ? "add_item" : "drop_item"
    subformat(Auth.current.field(:disabled_roles, new: {})).card_form :update do
      [check_box_tag(name, card.id, !card.disabled?, class: "_edit-item"),
       render_link]
    end
  end
end
