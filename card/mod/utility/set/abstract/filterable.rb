format :html do
  def filterable key, value=nil, opts={}
    add_class opts, "filterable"
    value ||= card.name
    opts[:data] ||= {}
    opts[:data].merge! filter_data(key, value)
    wrap_with :div, yield, opts
  end

  def filter_data key, value
    { filter: { key: key, value: value } }
  end

  def filtering
    wrap_with :div, yield, class: "filtering"
  end
end
