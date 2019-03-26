format :html do
  view :nest_rules, cache: :never, tags: :unknown_ok do
    output [rules_filter, quick_edit_rules_list(:field_related)]
  end

  def quick_edit_rules_list list
    setting_list(list)
  end
end
