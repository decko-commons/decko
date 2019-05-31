format :html do
  def filterable key, value=nil, opts={}
    add_class opts, "_filterable"
    value ||= card.name
    opts[:data] ||= {}
    opts[:data].merge! filter_data(key, value)
    wrap_with :div, yield, opts
  end

  def filter_data key, value
    { filter: { key: key, value: value } }
  end

  def filtering selector=nil
    selector ||= "._filter-widget:visible"
    wrap_with :div, yield, class: "_filtering", "data-filter-selector": selector
  end
end
