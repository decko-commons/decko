format :html do
  def filterable key, value, opts={}
    add_class opts, "filterable"
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