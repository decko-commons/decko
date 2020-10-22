format :html do
  # sort and filter ui
  view :filter_form, cache: :never do
    filter_fields slot_selector: "._filter-result-slot",
                  sort_field: _render(:sort_formgroup)
  end

  view :quick_filters, cache: :never do
    return "" unless quick_filter_list.present?

    haml :quick_filters, filter_list: normalized_quick_filter_list
  end

  def normalized_quick_filter_list
    quick_filter_list.map do |hash|
      hash = hash.clone
      filter_key = hash.keys.first
      {
        text: (hash.delete(:text) || hash[filter_key]),
        icon: (hash.delete(:icon) || mapped_icon_tag(filter_key)),
        # FIXME: mapped_icon_tag is a wikirate concept
        class:  css_classes(hash.delete(:class),
                            "_filter-link quick-filter-by-#{filter_key}"),
        filter: JSON(hash[:filter] || hash)
      }
    end
  end

  # for override
  def quick_filter_list
    []
  end

  # for override
  def custom_quick_filters
    ""
  end

  # @param data [Hash] the filter categories. The hash needs for every category
  #   a hash with a label and a input_field entry.
  def filter_form data={}, sort_input_field=nil, form_args={}
    haml :filter_form, categories: data,
                       sort_input_field: sort_input_field,
                       form_args: form_args
  end

  def filter_fields slot_selector: nil, sort_field: nil
    form_args = { action: filter_action_path, class: "slotter" }
    form_args["data-slot-selector"] = slot_selector if slot_selector
    filter_form filter_form_data, sort_field, form_args
  end

  def filter_form_data
    all_filter_keys.each_with_object({}) do |cat, h|
      h[cat] = { label: filter_label(cat),
                 input_field: _render("filter_#{cat}_formgroup"),
                 active: active_filter?(cat),
                 default: default_filter?(cat) }
    end
  end

  def active_filter? field
    if filter_keys_from_params.present?
      filter_hash.key? field
    else
      default_filter? field
    end
  end

  def default_filter? field
    default_filter_hash.key? field
  end

  def filter_label field
    # return "Keyword" if field.to_sym == :name
    #
    filter_label_from_method(field) || filter_label_from_name(field)
  end

  def filter_label_from_method field
    try "#{field}_filter_label"
  end

  def filter_label_from_name field
    Card.fetch_name(field) { field.to_s.titleize }
  end

  def filter_action_path
    path
  end

  view :sort_formgroup, cache: :never do
    select_tag "sort",
               options_for_select(sort_options, current_sort),
               class: "pointer-select _filter-sort form-control",
               "data-minimum-results-for-search": "Infinity"
  end
end
