format do
  view :template_nest, cache: :never, unknown: true do
    return "" unless voo.nest_name

    if voo.nest_name.to_name.field_only?
      with_nest_mode :normal do
        nest template_link_set_name, view: :template_link
      end
    else
      "{{#{voo.nest_syntax}}}"
    end
  end

  def template_link_set_name
    name = voo.nest_name.to_name
    if name.absolute?
      name.trait_name :self
    else
      template_link_set_name_for_relative_name name
    end
  end

  def template_link_set_name_for_relative_name name
    name = name.stripped.gsub(/^\+/, "")

    if (type = on_type_set)
      [type, name].to_name.trait_name :type_plus_right
    else
      name.to_name.trait_name :right
    end
  end

  def on_type_set
    return unless
      (tmpl_set_name = parent.card.name.trunk_name) &&
      (tmpl_set_class_name = tmpl_set_name.tag_name) &&
      (tmpl_set_class_card = Card[tmpl_set_class_name]) &&
      (tmpl_set_class_card.codename == :type)

    tmpl_set_name.left_name
  end
end