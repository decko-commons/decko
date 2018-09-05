format :html do
  view :bridge_rules_tab, cache: :never do
    rules_table =
      wrap do
        render_common_rules hide: [:content, :set_label, :set_navbar, :rule_navbar]
      end
    output [ rules_filter, rules_table ]
  end

  def setting_select
    select_tag(:view, options_for_select(
      [["Common", "common_rules"], ["All", "all_rules"], ["Grouped", :grouped_rules],
       ["Field", :field_related_rules], ["Recent", :recent_rules]]),
               class: "_submit-on-select form-control")
  end

  def set_select
    options = card.related_sets(true).map do |name, label|
      [label, name.to_name.url_key]
    end
    select_tag(:mark,
               options_for_select(options),
               class: "_submit-on-select form-control")
  end

  def rules_filter
    form_tag path(mark: "", slot: { hide: [:set_label, :rule_navbar, :set_navbar, :content] }),
             remote: true, method: "get", role: "filter",
             "data-slot-selector": "#home-rule_tab > .card-slot > .card-slot",
             class: classy("nodblclick slotter form-inline m-2") do
      output [
               label_tag(:view, "Filter", class: "mr-2"),
               setting_select,
               content_tag(:span, "rules that apply to set ...", class: "ml-2"),
               set_select
      ]
    end
  end
end
