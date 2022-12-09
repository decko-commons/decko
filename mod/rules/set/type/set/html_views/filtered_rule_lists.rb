format :html do
  view :nest_rules, cache: :never, unknown: true,
       wrap: :slot do
    render :quick_edit_setting_list
  end

  view :modal_nest_rules, cache: :never, unknown: true,
       wrap: { modal: { title: "Rules for nest" } } do
    filtered_rule_list :quick_edit_setting_list, :field_related, :self
  end

  view :bridge_rules_tab, cache: :never,
       wrap: { slot: { class: "d-flex flex-column gap-3 mx-3 mt-2" } }  do
    class_up "accordion-item", "_setting-list"
    filtered_rule_list :accordion_rule_list, :common, :related, mark: ""
  end

  view :filtered_accordion_rule_list do
    filtered_rule_list :accordion_rule_list
  end
end