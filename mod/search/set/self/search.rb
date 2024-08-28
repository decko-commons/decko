def match_start_only?
  Card.config.search_box_match_start_only
end

format do
  delegate :match_start_only?, to: :card

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

  def cql_keyword?
    search_keyword&.match?(/^\{.+\}$/)
  end

  def complete_path
    path mark: :search, view: :search_box_complete, format: :json
    # path mark: :search, view: :test, format: :json
  end

  def results_path keyword
    path mark: :search, query: { keyword: keyword }
  end
end

format :html do
  view :search_box, template: :haml, cache: :never

  view :title do
    voo.title ||= t(:search_results_title)
    super()
  end

  view :core, cache: :never do
    [render_results_for_keyword, super()]
  end

  view :results_for_keyword, cache: :never, template: :haml

  def search_item term
    autocomplete_item :search, icon_tag(:search), term
  end

  private

  def search_form &block
    form_tag path, method: "get", role: "search", class: classy("search-box-form"), &block
  end

  def search_box_contents
    text_field_tag "query[keyword]", search_keyword,
                   class: "_search-box #{classy 'search-box'} form-control w-100",
                   autocomplete: :off,
                   data: { completepath: complete_path },
                   placeholder: t(:search_search_box_placeholder)
  end
end

format :json do
  view :search_box_complete, cache: :never do
    search_box_items :search_item, :add_item, :goto_items
  end

  view :complete, cache: :never do
    complete_or_match_search(start_only: match_start_only?).map do |name|
      goto_item_label name
    end
  end

  private

  def search_box_items *methods
    [].tap do |items|
      each_search_box_item methods do |action, value, label, data|
        items << data.merge(action: action, value: value, label: label)
      end
    end
  end

  def each_search_box_item methods, &block
    term = search_keyword
    exact = Card.fetch term, new: {}
    methods.map { |method| send method, term, exact, &block }
  end

  def search_item term, _exact
    yield :search, term, card.format.search_item(term), url: card_url(results_path(term))
  end

  def add_item term, exact
    return unless exact.add_autocomplete_ok?

    fmt = exact.format
    yield :add, term, fmt.render_add_autocomplete_item,
          url: card_url(fmt.add_autocomplete_item_path)
  end

  def goto_items _term, exact
    map_goto_items exact do |item|
      yield :goto, item, goto_item_label(item), url: path(mark: item)
    end
  end

  def goto_item_label item
    item.card.format.render_goto_autocomplete_item
  end

  def map_goto_items exact, &block
    goto_names = complete_or_match_search start_only: match_start_only?
    goto_names.unshift exact.name if go_to_exact_match? exact
    goto_names.uniq.map(&block)
  end

  def go_to_exact_match? exact
    exact.known?
  end

  def term_param
    # return nil unless query_params.present?
    #
    # term = query_params[:keyword]
    return unless (term = super)&.present?

    if (term =~ /^\+/) && (main = params["main"])
      term = main + term
    end
    term
  end
end
