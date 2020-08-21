include_set Abstract::PagingParams

format do
  def limit
    limit_param
  end

  def offset
    offset_param
  end

  def search_with_params
    card.item_names
  end

  def count_with_params
    card.item_names.count
  end

  def total_pages
    return 1 if limit.zero?
    ((count_with_params - 1) / limit).to_i
  end

  def current_page
    (offset / limit).to_i
  end

  # for override
  def extra_paging_path_args
    {}
  end
end

format :html do
  PAGE_LI_CLASS = { ellipses: "disabled", current: "active" }.freeze

  def with_paging path_args={}
    with_paging_path_args path_args do
      output [yield(@paging_path_args), _render_paging]
    end
  end

  view :paging, cache: :never do
    return "" unless paging_needed?
    <<-HTML
      <nav>
        <ul class="pagination paging">
          #{paging_links.join}
        </ul>
      </nav>
    HTML
  end

  def paging_links
    PagingLinks.new(total_pages, current_page)
               .build do |text, page, status, options|
      page_link_li text, page, status, options
    end
  end

  # First page is 0 (not 1)
  def page_link_li text, page, status, options={}
    wrap_with :li, class: page_link_li_class(status) do
      page_link text, page, options
    end
  end

  def page_link_li_class status
    ["page-item", PAGE_LI_CLASS[status]].compact.join " "
  end

  def page_link text, page, options
    return content_tag(:div, text.html_safe, class: "page-link") unless page

    options.merge! class: "card-paging-link slotter page-link",
                   remote: true,
                   path: page_link_path_args(page)
    link_to raw(text), options
  end

  def with_paging_path_args args
    tmp = @paging_path_args
    @paging_path_args = paging_path_args args
    yield
  ensure
    @paging_path_args = tmp
  end

  def paging_path_args local_args={}
    @paging_path_args ||= {}
    @paging_path_args.reverse_merge!(limit: limit, offset: offset)
    @paging_path_args.merge! extra_paging_path_args
    @paging_path_args.merge local_args
  end

  def page_link_path_args page
    paging_path_args.merge offset: page * limit
  end

  def paging_needed?
    return false if limit < 1
    return false if fewer_results_than_limit? # avoid extra count search

    # count search result instead
    limit < count_with_params
  end

  # clear we don't need paging even before running count query
  def fewer_results_than_limit?
    return false unless offset.zero?

    limit > offset + search_with_params.length
  end
end

format :json do
  def page_link_path_args page
    {
      limit: limit,
      offset: page * limit,
      item: default_item_view, # hack. need standard voo handling
      format: :json
    }.merge extra_paging_path_args
  end

  view :paging_urls, cache: :never do
    return {} unless total_pages > 1

    { paging: paging_urls_hash }
  end

  def paging_urls_hash
    hash = {}
    PagingLinks.new(total_pages, current_page)
               .build do |_text, page, status, _options|
      add_paging_url hash, page, status
    end
    hash
  end

  def add_paging_url hash, page, status
    return unless page && status.in?(%i[next previous])

    hash[status] = path page_link_path_args(page)
  end
end
