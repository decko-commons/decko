format :html do
  bar_cols 7, 5
  info_bar_cols 5, 4, 3

  def existing_rule_card
      @existing_rule_card ||= find_existing_rule_card
  end

  view :bar, unknown: true do
    voo.hide :bar_nav unless existing_rule_card
    super()
  end

  view :expanded_bar, unknown: true do
    super()
  end

  view :bar_bottom, unknown: true do
    if nest_mode == :edit
      current_rule_form
    else
      nest existing_rule_card, view: :core
    end
  end

  view :bar_middle, unknown: true do
    rule_info
  end

  view :bar_right, unknown: true do
    return missing_link("#{fa_icon 'plus-square'} #{card.name}") unless existing_rule_card

    voo.show?(:bar_bottom) ? rule_info : rule_short_content
  end

  def rule_short_content
    return "" unless existing_rule_card

    nest existing_rule_card, { view: :one_line_content }, set_context: card.name.trunk_name
  end

  def bar_title
    return super() if voo.show? :full_name

    if existing_rule_card && voo.show?(:toggle)
      link_to_view bar_title_toggle_view, card.rule_setting_title
    else
      card.rule_setting_title
    end
  end

  def rule_info
    return wrap_with(:em, "no existing #{setting_link} rule") unless existing_rule_card

    "<span>#{rule_setting_link} rule that applies to #{rule_set_link existing_rule_card}</span>"
  end

  def rule_setting_link
    link_to_card card.rule_setting, card.rule_setting_name
  end

  def rule_set_link existing_rule
    count = link_to_card [card.rule_set, :by_name], card.rule_set.count
    "#{link_to_card card.rule_set, existing_rule.trunk&.label.downcase} (#{count})"
  end
end
