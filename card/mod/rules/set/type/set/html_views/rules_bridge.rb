format :html do
  view :bridge_rules_tab, cache: :never do
    output [rules_filter, render_rules_list]
  end

  view :rules_list, wrap: :slot do
    group = params[:group]&.to_sym || :common
    rules_list group, setting_list(group)
  end

  def rules_list _key, items
    bridge_pills(items.map { |i| rules_list_item i })
  end

  def rules_list_item setting
    return "" unless show_view? setting

    rule_card = card.fetch trait: setting, new: {}
    nest(rule_card, view: :rule_bridge_link).html_safe
  end
end
