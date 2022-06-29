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

  # TODO: unify with term_param
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
    search_form { search_box_contents }
  end

  view :title do
    voo.title ||= t(:search_results_title)
    super()
  end

  view :core, cache: :never do
    [render_results_for_keyword, super()]
  end

  view :results_for_keyword, cache: :never, template: :haml

  def search_form &block
    form_tag path, method: "get", role: "search", class: classy("search-box-form"), &block
  end

  def search_box_contents
    keyword = query_params[:keyword]
    select_tag "query[keyword]", options_for_select([keyword].compact, keyword),
               class: "_search-box #{classy 'search-box'} form-control w-100",
               placeholder: t(:search_search_box_placeholder)
  end

  def search_item term
    autocomplete_item icon_tag(:search), term
  end
end

format :json do
  view :search_box_complete, cache: :never do
    search_box_items :search_item, :add_item, :goto_items
  end

  view :complete, cache: :never do
    { result: complete_or_match_search(start_only: match_start_only?) }
  end

  # TODO: move to carrierwave mod
  view :image_complete, cache: :never do
    { result: image_items }
  end

  private

  def search_box_items *methods
    term_and_exact do |term, exact|
      methods.map do |method|
        send method, term, exact
      end.flatten.compact
    end
  end

  def search_item term, _exact
    { id: term, text: card.format.search_item(term) }
  end

  def term_and_exact
    term = term_param
    yield term, Card.fetch(term, new: {})
  end

  def match_start_only?
    Card.config.search_box_match_start_only
  end

  def add_item term, exact
    exact.format(:json).add_autocomplete_item term
  end

  def goto_items term, exact
    map_goto_items exact do |item|
      { id: term, href: item.url_key, text: goto_item_text(item) }
    end
  end

  # TODO handle highlighting (with #highlight method)
  def goto_item_text item
    item.card.format.render :goto_autocomplete_item
  end

  def map_goto_items exact, &block
    goto_names = complete_or_match_search start_only: match_start_only?
    goto_names.unshift exact.name if exact.known?
    goto_names.uniq.map &block
  end

  def term_param
    return nil unless query_params.present?

    term = query_params[:keyword]
    if (term =~ /^\+/) && (main = params["main"])
      term = main + term
    end
    term
  end

  def image_items
    complete_or_match_search(start_only: match_start_only?,
                             additional_cql: { type: :image }).map do |name|
      [name, h(card.format("html").nest(name, view: :core, size: :icon))]
    end
  end
end
