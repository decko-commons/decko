format :html do
  view :bridge_rules_tab, cache: :never do
    haml :compact_rules_table, settings: (card.visible_setting_codenames.sort & COMMON_RULE_SETTINGS)
  end

  def rules_filter
    form_tag path(mark: card, slot: { hide: [:set_label, :rule_navbar, :set_navbar, :content] }),
             remote: true, class: "slotter",
             method: "get", role: "filter",
             "data-slot-selector": "#home-rule_tab > .card-slot > .card-slot",
             class: classy("nodblclick slotter form-inline m-2") do
      output [
               label_tag(:view, "Filter", class: "mr-2"),
               select_tag(:view, options_for_select(
        [["Common", "common_rules"], ["All", "all_rules"], ["Grouped", :grouped_rules],
        ["Field", :field_related_rules]]),
                 class: "_submit-on-select form-control"),
               content_tag(:span, "rules", class: "ml-2")
      ]
    end
  end
end
