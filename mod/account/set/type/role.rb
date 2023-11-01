card_accessor :members

def disabled?
  Auth.current&.fetch(:disabled_roles)&.item_ids&.include? id
end

format :html do
  view :link_with_checkbox, cache: :never do
    role_checkbox
  end

  view :configs do
    configs_by_cat = card.all_admin_configs_grouped_by(:roles, :category)[card.codename]
    configs_by_cat.map do |(cat, configs)|
      if cat == "cardtypes"
        nested_list_section cat.capitalize,
                            card.config_codenames_grouped_by_title(configs)
      elsif cat == "views"
        next
      else
        list_section cat.capitalize, configs.map { |c| c.codename.to_sym }, :closed_bar
      end
    end
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
