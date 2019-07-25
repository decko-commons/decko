format :html do
  GROUP = {
    "Content" => %w[RichText PlainText Phrase Date Number Toggle Markdown File Image URI],
    "Custom" => [],
    "Organize" => ["Cardtype", "Search", "List", "Link list", "Pointer",
                   "Mirror list", "Mirrored list"],
    "Admin" => ["Layout", "Skin", "User", "Role",
                "Notification template", "Email template", "Twitter template" ],
    "Code" => ["HTML", "Json", "CSS", "SCSS", "JavaScript", "CoffeeScript"]
  }.freeze

  # group for each cardtype: { "RichText => "Content", "Layout" => "Admin", ... }
  GROUP_MAP = GROUP.each_with_object({}) do |(cat, types), h|
                types.each { |t| h[t] = cat }
  end

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
    if voo.visible?(:type_form) { false }
      return _render_bridge_type_formgroup
    end
    edit_row_fixed_width "Type", link_to_card(card.type), :bridge_type_formgroup
  end

  view :bridge_type_formgroup, wrap: :slot do
    type_formgroup href: path(mark: card.id, view: :edit_content_form, type_reload: true, slot: { show: :type_form }),
                   class: "live-type-field slotter",
                   'data-remote': true,
                   'data-slot-selector': '.card-slot.edit_content_form-view'
  end

  def type_formgroup args={}
    add_class args, "type-field"
    wrap_type_formgroup do
      type_field args
    end
  end

  view :type_formgroup do
    type_formgroup
  end

  def type_field args={}
    typelist = Auth.createable_types
    current_type = type_field_current_value args, typelist
    options = grouped_options_for_select grouped_types(current_type), current_type
    template.select_tag "card[type]", options, args
  end

  def grouped_types current_type
    groups = Hash.new { |h, k| h[k] = [] }
    allowed = ::Set.new Auth.createable_types
    allowed << current_type if current_type

    GROUP.each_pair do |name, items|
      items.each do |i|
        groups[name] << i if allowed.include?(i)
      end
    end
    Auth.createable_types.each do |type|
      groups["Custom"] << type unless GROUP_MAP[type]
    end
    groups
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
