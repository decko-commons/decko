include_set Abstract::FilterHelper

format :html do
  view :filter_name_formgroup, cache: :never do
    text_filter :name
  end

  def sort_options
    {}
  end

  def select_filter field, _label=nil, default=nil, options=nil
    options ||= filter_options field
    options.unshift(["--", ""]) unless default
    select_filter_tag field, default, options
  end

  def multiselect_filter field, _label=nil, default=nil, options=nil
    options ||= filter_options field
    multiselect_filter_tag field, default, options
  end

  def text_filter field, opts={}
    name = filter_name field
    add_class opts, "form-control"
    # formgroup filter_label(field), class: "filter-input" do
    text_field_tag name, filter_param(field), opts
    # end
  end

  def select_filter_type_based type_codename, order="asc"
    # take the card name as default label
    options = type_options type_codename, order, 80
    select_filter type_codename, nil, nil, options
  end

  def autocomplete_filter type_code, options_card=nil
    options_card ||= Card::Name[type_code, :type, :by_name]
    text_filter type_code, class: "#{type_code}_autocomplete",
                           "data-options-card": options_card
  end

  def multiselect_filter_type_based type_codename
    options = type_options type_codename
    multiselect_filter type_codename, nil, nil, options
  end

  def multiselect_filter_tag field, default, options, html_options={}
    html_options[:multiple] = true
    select_filter_tag field, default, options, html_options
  end

  def select_filter_tag field, default, options, html_options={}
    name = filter_name field, html_options[:multiple]
    default = filter_param(field) || default
    options = options_for_select(options, default)

    css_class =
      html_options[:multiple] ? "pointer-multiselect" : "pointer-select"
    add_class(html_options, css_class + " filter-input #{field} _filter_input_field")

    select_tag name, options, html_options
  end

  def filter_name field, multi=false
    "filter[#{field}]#{'[]' if multi}"
  end

  def filter_options field
    raw = send("#{field}_options")
    raw.is_a?(Array) ? raw : option_hash_to_array(raw)
  end

  def option_hash_to_array hash
    hash.each_with_object([]) do |(key, value), array|
      array << [key, value.to_s.downcase]
      array
    end
  end

  def type_options type_codename, order="asc", max_length=nil
    type_card = Card[type_codename]
    res = Card.search type_id: type_card.id, return: :name, sort: "name", dir: order
    return res unless max_length
    res.map { |i| i.size > max_length ? "#{i[0..max_length]}..." : i }
  end
end
