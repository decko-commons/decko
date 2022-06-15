format do
  view :search_error, cache: :never do
    # don't show card content; not very helpful in this case
    %(#{search_with_params.class} :: #{search_with_params.message})
  end

  def search_with_params
    @search_with_params ||= cql_keyword? ? cql_search : super
  end

  def cql_search
    query = card.parse_json_cql search_keyword
    rescuing_bad_query(query) { Card.search query }
  end

  def search_keyword
    @search_keyword ||= search_vars&.dig :keyword
  end

  def search_vars
    root.respond_to?(:search_params) ? root.search_params[:vars] : search_params[:vars]
  end

  def cql_keyword?
    search_keyword&.match?(/^\{.+\}$/)
  end
end

format :html do
  view :search_box, cache: :never do
    form_tag path, method: "get", role: "search",
                   class: classy("search-box-form", "nodblclick") do
      select_tag "query[keyword]", "",
                 class: "_search-box search-box form-control w-100",
                 placeholder: t(:search_search_box_placeholder)
    end
  end

  view :title, cache: :never do
    (title = keyword_search_title) ? (voo.title = title) : super()
  end

  def keyword_search_title
    search_keyword &&
      %(Search results for: <span class="search-keyword">#{h search_keyword}</span>)
  end
end

format :json do
  view :search_box_complete, cache: :never do
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

  view :complete, cache: :never do
    { result: complete_or_match_search(start_only: match_start_only?) }
  end

  # TODO: move to carrierwave mod
  view :image_complete, cache: :never do
    { result: image_items }
  end

  private

  def match_start_only?
    Card.config.search_box_match_start_only
  end

  def add_item exact
    return unless exact.new_card? &&
                  exact.name.valid? &&
                  !exact.virtual? &&
                  exact.ok?(:create)

    [h(exact.name), ERB::Util.url_encode(exact.name)]
  end

  def new_item_of_type exact
    return unless (exact.type_id == CardtypeID) &&
                  Card.new(type_id: exact.id).ok?(:create)

    [exact.name, "new/#{exact.name.url_key}"]
  end

  def goto_items term, exact, additional_cql: {}
    goto_names = complete_or_match_search start_only: match_start_only?,
                                          additional_cql: additional_cql
    goto_names.unshift exact.name if add_exact_to_goto_names? exact, goto_names
    goto_names.map do |name|
      [name, name.to_name.url_key, h(highlight(name, term, sanitize: false))]
    end
  end

  def add_exact_to_goto_names? exact, goto_names
    exact.known? && !goto_names.find { |n| n.to_name.key == exact.key }
  end

  def term_param
    return nil unless query_params

    term = query_params[:keyword]
    if (term =~ /^\+/) && (main = params["main"])
      term = main + term
    end
    term
  end

  def image_items
    complete_or_match_search(start_only: match_start_only?,
                             additional_cql: { type: :image }).map do
      [name, h(card.format("html").nest(name, view: :core, size: :icon))]
    end
  end
end
