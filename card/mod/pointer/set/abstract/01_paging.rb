include_set Abstract::PagingParams

format do
  def limit
    limit_param
  end

  def offset
    offset_param
  end

  def search_with_params args={}
    card.item_names(args)
  end

  def count_with_params args={}
    card.item_names(args).count
  end
end

format :html do
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
    total_pages = ((count_with_params - 1) / limit).to_i
    current_page = (offset / limit).to_i
    PagingLinks.new(total_pages, current_page)
               .build do |text, page, status, options|
      page_link_li text, page, status, options
    end
  end

  # First page is 0 (not 1)
  def page_link_li text, page, status, options={}
    wrap_with :li, class: "page-item #{status}" do
      page_link text, page, options
    end
  end

  def page_link text, page, options
    return content_tag(:div, text.html_safe, class: "page-link") unless page
    options.merge! class: "card-paging-link slotter page-link",
                   remote: true,
                   path: paging_path_args(offset: page * limit)
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
    @paging_path_args.reverse_merge!(
      limit: limit,
      offset: offset,
      view: paging_view,
      slot: voo.slot_options
    )
    @paging_path_args.merge! extra_paging_path_args
    @paging_path_args.merge local_args
  end

  def paging_view
    (voo && voo.home_view) || voo.slot_options[:view] || :content
  end

  def extra_paging_path_args
    {}
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
