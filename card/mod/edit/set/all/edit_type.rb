format :html do
  view :edit_type, cache: :never, perms: :update do
    frame do
      _render_edit_type_form
    end
  end

  view :edit_type_form, cache: :never, perms: :update, wrap: :slot do
    card_form :update, success: edit_type_success do
      [type_formgroup, render_new_buttons]
    end
  end

  def edit_type_success
    { view: :core }
  end

  view :edit_type_row do
    return _render_bridge_type_formgroup if voo.visible?(:type_form) { false }

    edit_row_fixed_width "Type", link_to_card(card.type), :bridge_type_formgroup
  end

  view :bridge_type_formgroup, unknown: true, wrap: :slot do
    type_formgroup href: path(mark: card.id,
                              view: :edit_form,
                              assign: true,
                              slot: { show: :type_form }),
                   class: "live-type-field slotter",
                   'data-remote': true,
                   'data-slot-selector': ".card-slot.edit_form-view"
  end

  view :type_formgroup do
    type_formgroup
  end

  def type_formgroup args={}
    add_class args, "type-field"
    wrap_type_formgroup do
      type_field args
    end
  end

  def wrap_type_formgroup
    formgroup "Type", input: "type", class: "type-formgroup", help: false do
      output [yield, hidden_field_tag(:assign, true)]
    end
  end

  def type_field args={}
    typelist = Auth.createable_types
    current_type = type_field_current_value args, typelist
    template.select_tag "card[type]", type_field_options(current_type),
                        args.merge("data-select2-id": "#{unique_id}-#{Time.now.to_i}")
  end

  def type_field_options current_type
    types = grouped_types(current_type)

    if types.size == 1
      options_for_select types.flatten[1], current_type
    else
      grouped_options_for_select types, current_type
    end
  end

  def grouped_types current_type
    groups = Hash.new { |h, k| h[k] = [] }
    allowed = ::Set.new Auth.createable_types
    allowed << current_type if current_type

    visible_cardtype_groups.each_pair do |name, items|
      if name == "Custom"
        Auth.createable_types.each do |type|
          groups["Custom"] << type unless ::Card::Set::Self::Cardtype::GROUP_MAP[type]
        end
      else
        items.each do |i|
          groups[name] << i if allowed.include?(i)
        end
      end
    end
    groups
  end

  def visible_cardtype_groups
    ::Card::Set::Self::Cardtype::GROUP
  end

  def type_field_current_value args, typelist
    return if args.delete :no_current_type

    if !card.new_card? && !typelist.include?(card.type_name)
      # current type should be an option on existing cards,
      # regardless of create perms
      typelist.push(card.type_name).sort!
    end
    card.type_name_or_default
  end
end
