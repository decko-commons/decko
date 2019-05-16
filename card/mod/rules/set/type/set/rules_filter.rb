format :html do
  def rules_filter selected_setting=:common, set_options=:related
    form_tag path(mark: "", view: :rules_list, slot: { hide: :content }),
             remote: true, method: "get", role: "filter",
             "data-slot-selector": ".card-slot.rules_list-view",
             class: classy("nodblclick slotter form-inline slim-select2 m-2") do
      output [
        label_tag(:view, icon_tag("filter_list"), class: "mr-2"),
        setting_select(selected_setting),
        content_tag(:span, "rules that apply to set ...", class: "mx-2 small"),
        set_select(set_options)
      ]
    end
  end

  def setting_select selected=nil
    select_tag(:group, grouped_options_for_select(setting_options, selected),
               class: "_submit-on-select form-control")
  end

  def set_select set_options=:related
    select_tag(:mark, set_select_options(set_options),
               class: "_submit-on-select form-control",
               "data-minimum-results-for-search": "Infinity")
  end

  def selected_set
    params[:set]
  end

  def set_select_options set_options
    options =
      if set_options == :related || card.type_id != Card::SetID
        related_set_options
      else
        [[card.label, card.name.url_key]]
      end
    options_for_select(options, selected_set)
  end

  def related_set_options
    card.related_sets(true).map do |name, label|
      [label, name.to_name.url_key]
    end
  end
end
