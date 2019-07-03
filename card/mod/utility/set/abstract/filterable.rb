format :html do
  def filterable filter_hash={}, html_opts={}
    add_class html_opts, "_filterable _noFilterUrlUpdates"
    html_opts[:data] ||= {}
    html_opts[:data][:filter] = filter_hash
    wrap_with :div, yield, html_opts
  end

  def filtering selector=nil
    selector ||= "._filter-widget:visible"
    wrap_with :div, yield, class: "_filtering", "data-filter-selector": selector
  end
end
