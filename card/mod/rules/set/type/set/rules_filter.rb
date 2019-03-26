format :html do
  def rules_filter
    form_tag path(mark: "", view: :rules_list, slot: { hide: :content }),
             remote: true, method: "get", role: "filter",
             "data-slot-selector": ".card-slot.rules_list-view",
             class: classy("nodblclick slotter form-inline slim-select2 m-2") do
      output [
               label_tag(:view, icon_tag("filter_list"), class: "mr-2"),
               setting_select,
               content_tag(:span, "rules that apply to set ...", class: "mx-2 small"),
               set_select
             ]
    end
  end

  def setting_select
    select_tag(:group, grouped_options_for_select(setting_options),
               class: "_submit-on-select form-control")
  end

  def set_select
    select_tag(:mark, set_select_options,
               class: "_submit-on-select form-control",
               "data-minimum-results-for-search": "Infinity")
  end

  def set_select_options
    options =
      card.related_sets(true).map do |name, label|
        [label, name.to_name.url_key]
      end
    options_for_select(options)
  end
end
