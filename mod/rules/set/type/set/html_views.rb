format :html do
  before :open do
    voo.hide :template_closer
  end

  view :core, cache: :never do
    filtered_rule_list :bar_rule_list
  end

  view :nest_rules, cache: :never, unknown: true, wrap: :slot do
    filtered_rule_list :modal_pill_rule_list, :field_related_rules, :related, mark: ""
  end

  view :modal_nest_rules, cache: :never, unknown: true,
                          wrap: { modal: { title: "Rules for nest" } } do
    filtered_rule_list :quick_edit_rule_list, :field_related_rules, :self
  end

  view :bridge_rules_tab, cache: :never do
    filtered_rule_list :pill_rule_list, :common, :related, mark: ""
  end

  def filtered_rule_list view, *filter_args
    [rules_filter(view, *filter_args),
     render(view)]
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

  def setting_group default=:common
    voo&.filter&.to_sym || params[:group]&.to_sym || default
  end

  view :input do
    "Cannot currently edit Sets" # LOCALIZE
  end

  view :one_line_content, wrap: {} do
    ""
  end
end
