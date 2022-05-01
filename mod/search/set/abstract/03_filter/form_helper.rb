include_set Abstract::FilterHelper

format :html do
  view :filter_name_formgroup, cache: :never do
    text_filter :name
  end

  def select_filter field, default=nil, options=nil
    options ||= filter_options field
    options = [["--", ""]] + options unless default
    select_filter_tag field, default, options
  end

  def multiselect_filter field, default=nil, options=nil
    options ||= filter_options field
    multiselect_filter_tag field, default, options
  end

  def text_filter field, default=nil, opts={}
    value = filter_param(field) || default
    text_filter_with_name_and_value filter_name(field), value, opts
  end

  def text_filter_with_name_and_value name, value, opts
    opts[:class] ||= "simple-text"
    add_class opts, "form-control"
    text_field_tag name, value, opts
  end

  def range_filter field, default={}, opts={}
    add_class opts, "simple-text range-filter-field"
    default ||= {}
    output [range_sign(:from),
            sub_text_filter(field, :from, default, opts),
            range_sign(:to),
            sub_text_filter(field, :to, default, opts)]
  end

  def range_sign side
    dir = side == :from ? "right" : "left"
    fa_icon("chevron-circle-#{dir}", class: "input-group-text")
  end

  def sub_text_filter field, field, default={}, opts={}
    name = "filter[#{field}][#{field}]"
    value = filter_hash.dig(field, field) || default[field]
    text_filter_with_name_and_value name, value, opts
  end

  def autocomplete_filter type_code, options_card=nil
    options_card ||= Card::Name[type_code, :type, :by_name]
    text_filter type_code, "", class: "#{type_code}_autocomplete",
                               "data-options-card": options_card
  end

  def multiselect_filter_tag field, default, options, html_options={}
    html_options[:multiple] = true
    select_filter_tag field, default, options, html_options
  end

  def select_filter_tag field, default, options, html_options={}
    name = filter_name field, html_options[:multiple]
    options = options_for_select options, (filter_param(field) || default)
    normalize_select_filter_tag_html_options field, html_options
    select_tag name, options, html_options
  end

  # alters html_options hash
  def normalize_select_filter_tag_html_options field, html_options
    pointer_suffix = html_options[:multiple] ? "multiselect" : "select"
    add_class html_options, "pointer-#{pointer_suffix} filter-input #{field} " \
                            "_filter_input_field _no-select2 form-control"
    # _no-select2 because select is initiated after filter is opened.
    html_options[:id] = "filter-input-#{unique_id}"
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
      array << [key, value.to_s]
      array
    end
  end

  def type_options type_codename, order="asc", max_length=nil
    Card.cache.fetch "#{type_codename}-TYPE-OPTIONS" do
      res = Card.search type: type_codename, return: :name, sort: "name", dir: order
      max_length ? (res.map { |i| [trim_option(i, max_length), i] }) : res
    end
  end

  def trim_option option, max_length
    option.size > max_length ? "#{option[0..max_length]}..." : option
  end
end
