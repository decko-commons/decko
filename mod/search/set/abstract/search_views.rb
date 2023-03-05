format do
  view :core, cache: :never do
    _render search_result_view
  end

  def search_result_view
    case search_with_params
    when Exception              then :search_error
    when Integer                then :search_count
    when nest_mode == :template then :raw
    else                         :card_list
    end
  end
end

format :rss do
  view :feed_body do
    case raw_feed_items
    when Exception then @xml.item(render!(:search_error))
    when Integer then @xml.item(render!(:search_count))
    else super()
    end
  end

  def raw_feed_items
    @raw_feed_items ||= search_with_params
  end
end

format :html do
  view :core do
    _render search_result_view
  end

  view :bar do
    voo.hide :one_line_content
    super()
  end

  view :one_line_content, cache: :never do
    if depth > max_depth
      "..."
    else
      render_core hide: "paging", items: { view: :link }
      # TODO: if item is queryified to be "name", then that should work.
      # otherwise use link
    end
  end

  def rss_link_tag
    path_opts = { format: :rss }
    Array(search_params[:vars]).compact.each { |k, v| opts["_#{k}"] = v }
    tag "link", rel: "alternate",
                type: "application/rss+xml",
                title: "RSS",
                href: path(path_opts)
  end
end
