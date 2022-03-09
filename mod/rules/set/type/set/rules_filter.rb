format :html do
  def rules_filter view, selected_setting=nil, set_options=nil, path_opts={}
    form_tag path(path_opts.merge(view: view)),
             remote: true, method: "get", role: "filter",
             "data-slot-selector": ".card-slot.rule-list",
             class: classy("nodblclick slotter form-inline slim-select2 m-2") do
      output [
        label_tag(:view, icon_tag("filter_list"), class: "me-2"),
        setting_select(selected_setting),
        set_select(set_options)
      ].flatten
    end
  end

  def set_select set_options
    return filter_text.html_safe unless set_options

    [content_tag(:span, "rules that apply to set ...", class: "mx-2 small"),
     set_select_tag(set_options)]
  end

  def setting_select selected=nil
    select_tag(:group, grouped_options_for_select(setting_options, selected),
               class: "_submit-on-select form-control",
               "data-select2-id": "#{unique_id}-#{Time.now.to_i}")
  end

  def filter_text
    wrap_with :span, class: "mx-2 small" do
      "rules that apply to #{_render_set_label.downcase}" # LOCALIZE
    end
  end

  def set_select_tag set_options=:related
    select_tag(:mark, set_select_options(set_options),
               class: "_submit-on-select form-control _close-rule-overlay-on-select",
               "data-minimum-results-for-search": "Infinity",
               "data-select2-id": "#{unique_id}-#{Time.now.to_i}")
  end

  def selected_set
    params[:set]
  end

  def set_select_options set_options
    options =
      if set_options == :related
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
