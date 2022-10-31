format :html do
  before :open do
    voo.hide :template_closer
  end

  view :core, cache: :never do
    [
      set_select(:broader),
      filtered_rule_list(:bar_setting_list)
    ]
  end

  view :nest_rules, cache: :never, unknown: true, wrap: :slot do
    filtered_rule_list :quick_edit_setting_list, :field_related, :related, mark: ""
  end

  view :modal_nest_rules, cache: :never, unknown: true,
                          wrap: { modal: { title: "Rules for nest" } } do
    filtered_rule_list :quick_edit_setting_list, :field_related, :self
  end

  view :bridge_rules_tab, cache: :never, wrap: { slot: { class: "d-flex flex-column gap-3 mx-3 mt-2" } }  do
    class_up "accordion-item", "_setting-list"
    filtered_rule_list :accordion_rule_list, :common, :related, mark: ""
  end


  view :set_label do
    wrap_with :strong, card.label, class: "set-label"
  end

  view :input do
    "Cannot currently edit Sets" # LOCALIZE
  end

  view :one_line_content, wrap: {} do
    ""
  end
end
