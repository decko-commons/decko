format :html do
  before :open do
    voo.hide :template_closer
  end

  view :core, cache: :never do
    table_rules_filter + _render_rules_table
  end

  view :rules_table, cache: :never do
    rules_table setting_list(setting_group)
  end

  def table_rules_filter
    form_tag path(view: :rules_table, slot: { show: :content }),
             remote: true, method: "get", role: "filter",
             "data-slot-selector": ".card-slot.rules-table",
             class: classy("nodblclick slotter form-inline slim-select2 m-2") do
      output [
        label_tag(:view, icon_tag("filter_list"), class: "mr-2"),
        setting_select,
        content_tag(:span, "rules that apply to #{_render_set_label}".html_safe,
                    class: "mx-2 small")
      ]
    end
  end

  def setting_group
    params[:group]&.to_sym || :common
  end

  view :set_label do
    wrap_with :strong, card.label, class: "set-label"
  end

  Card::Setting.groups.each_key do |group_key|
    view group_key.to_sym do
      next unless card.visible_settings(group_key).present?

      haml :group_panel, group_key: group_key
    end
  end

  def rules_table settings
    class_up "card-slot", "rules-table"
    wrap do
      haml :rules_table, settings: settings,
                         item_view: voo.show?(:content) ? :closed_rule : :rule_link
    end
  end

  def rule_table_row setting
    return "" unless show_view? setting

    rule_card = card.fetch trait: setting, new: {}
    row_view, optional_content =
      voo.hide?(:content) ? %i[rule_link hide] : %i[rule_row show]

    nest(rule_card, view: row_view, optional_content => :content).html_safe
  end

  view :editor do
    "Cannot currently edit Sets" # LOCALIZE
  end

  view :closed_content do
    ""
  end
end
