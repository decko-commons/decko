def query_args args={}
  return super unless keyword_contains_cql? args
  args.merge parse_keyword_cql(args)
end

def parse_keyword_cql args
  parse_json_query(args[:vars][:keyword])
end

def keyword_contains_cql? hash
  hash[:vars] && (keyword = hash[:vars][:keyword]) && keyword =~ /^\{.+\}$/
end

format do
  view :search_error, cache: :never do
    sr_class = search_with_params.class.to_s

    # don't show card content; not very helpful in this case
    %(#{sr_class} :: #{search_with_params.message})
  end
end

format :html do
  view :title, cache: :never do
    return super() unless (keyword = search_keyword) &&
                          (title = keyword_search_title(keyword))
    voo.title = title
  end

  def keyword_search_title keyword
    %(Search results for: <span class="search-keyword">#{h keyword}</span>)
  end

  def search_keyword
    (vars = search_vars) && vars[:keyword]
  rescue Card::Error::PermissionDenied
    nil
  end

  def search_vars
    root.respond_to?(:search_params) ? root.search_params[:vars] : search_params[:vars]
  end

  def cql_search?
    card.keyword_contains_cql? vars: search_vars
  end
end

format :json do
  view :complete, cache: :never do
    term = term_param
    exact = Card.fetch term, new: {}

    {
      search: true,
      term: term,
      add: add_item(exact),
      new: new_item_of_type(exact),
      goto: goto_items(term, exact)
    }
  end

  def add_item exact
    return unless exact.new_card? &&
                  exact.name.valid? &&
                  !exact.virtual? &&
                  exact.ok?(:create)
    [h(exact.name), exact.name.url_key]
  end

  def new_item_of_type exact
    return unless (exact.type_id == CardtypeID) &&
                  Card.new(type_id: exact.id).ok?(:create)
    [exact.name, "new/#{exact.name.url_key}"]
  end

  def goto_items term, exact
    goto_names = complete_or_match_search start_only: Cardio.config.navbox_match_start_only
    goto_names.unshift exact.name if add_exact_to_goto_names? exact, goto_names
    goto_names.map do |name|
      [name, name.to_name.url_key, h(highlight(name, term, sanitize: false))]
    end
  end

  def add_exact_to_goto_names? exact, goto_names
    exact.known? && !goto_names.find { |n| n.to_name.key == exact.key }
  end

  def term_param
    term = query_params[:keyword]
    if (term =~ /^\+/) && (main = params["main"])
      term = main + term
    end
    term
  end
end
