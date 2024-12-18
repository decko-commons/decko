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
    return _render_board_type_formgroup if voo.visible?(:type_form) { false }

    edit_row "Type", link_to_card(card.type), :board_type_formgroup
  end

  view :board_type_formgroup, unknown: true, wrap: :slot do
    type_formgroup href: path(mark: card.id,
                              view: :edit_form,
                              assign: true,
                              slot: { show: :type_form }),
                   class: "_live-type-field",
                   'data-remote': true
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

  def type_field args={}
    @no_current_type = args.delete :no_current_type # just a test artifact?
    action_view.select_tag "card[type]", type_field_options,
                           args.merge("data-select2-id": "#{unique_id}-#{Time.now.to_i}")
  end

  private

  def raw_type_options
    return @raw_type_options if @raw_type_options

    options = Auth.createable_types
    if !@no_current_type && card.real? && !options.include?(card.type_name)
      # current type should be an option on existing cards,
      # regardless of create perms
      options.push(card.type_name).sort!
    end
    @raw_type_options = ::Set.new options
  end

  def wrap_type_formgroup
    formgroup "Type", input: "type", class: "type-formgroup", help: false do
      output [yield, hidden_field_tag(:assign, true)]
    end
  end

  def type_field_options
    if grouped_types.size == 1
      simple_type_field_options
    else
      multi_type_field_options
    end
  end

  def simple_type_field_options
    options_for_select grouped_types.flatten[1], current_type_value
  end

  def multi_type_field_options
    grouped_options_for_select grouped_types, current_type_value
  end

  def current_type_value
    return if @no_current_type

    @current_type_value ||= card.type_name_or_default
  end

  def grouped_types
    groups = Hash.new { |h, k| h[k] = [] }

    visible_cardtype_groups.each_pair.with_object(groups) do |(name, items), grps|
      if name == "Custom"
        groups[name] = custom_types
      else
        standard_grouped_types grps, name, items
      end
    end
  end

  def standard_grouped_types groups, name, items
    items.each do |i|
      groups[name] << i if raw_type_options.include?(i)
    end
  end

  def visible_cardtype_groups
    All::CardtypeGroups::GROUP
  end
end
