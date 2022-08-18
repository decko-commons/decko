include_set Type::List

card_accessor :members

def disabled?
  Auth.current&.fetch(:disabled_roles)&.item_ids&.include? id
end

format :html do
  view :link_with_checkbox, cache: :never do
    role_checkbox
  end

  def role_checkbox
    name = card.disabled? ? "add_item" : "drop_item"
    subformat(Auth.current.field(:disabled_roles)).card_form :update do
      [check_box_tag(name, card.id, !card.disabled?, class: "_edit-item"),
       render_link]
    end
  end

  def related_by_content_items
    super.unshift ["members", :members]
  end
end
