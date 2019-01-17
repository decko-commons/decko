
format do
  view :search_count, cache: :never do
    search_with_params.to_s
  end

  view :search_error, cache: :never do
    sr_class = search_with_params.class.to_s
    %(#{sr_class} :: #{search_with_params.message} :: #{card.content})
  end

  view :card_list, cache: :never do
    if search_with_params.empty?
      "no results"
    else
      search_with_params.map do |item_card|
        nest_item item_card
      end.join "\n"
    end
  end
end

format :json do
  AUTOCOMPLETE_LIMIT = 8 # number of name suggestions for autocomplete text fields

  def item_cards
    search_with_params
  end

  view :molecule, cache: :never do
    super().merge paging_urls
  end

  # TODO: design better autocomplete API
  view :name_complete, cache: :never do
    complete_search limit: AUTOCOMPLETE_LIMIT
  end

  view :name_match, cache: :never do
    complete_or_match_search limit: AUTOCOMPLETE_LIMIT
  end

  def complete_or_match_search limit: AUTOCOMPLETE_LIMIT
    starts_with = complete_search limit: limit
    remaining_slots = limit - starts_with.size
    return starts_with if remaining_slots.zero?
    starts_with + match_search(not_names: starts_with, limit: remaining_slots)
  end

  def complete_search limit: AUTOCOMPLETE_LIMIT
    card.search name_wql(limit).merge(complete_wql)
  end

  def match_search limit: AUTOCOMPLETE_LIMIT, not_names: []
    card.search name_wql(limit).merge(match_wql(not_names))
  end

  def name_wql limit
    { limit: limit, sort: "name", return: "name" }
  end

  def complete_wql
    { complete: term_param }
  end

  def match_wql not_names
    wql = { name_match: term_param }
    wql[:name] = ["not in"] + not_names if not_names.any?
    wql
  end

  def term_param
    params[:term]
  end
end

format :data do
  view :card_list do
    search_with_params.map do |item_card|
      nest_item item_card
    end
  end
end

format :csv do
  view :core, mod: All::AllCsv::CsvFormat

  view :card_list do
    items = super()
    if depth.zero?
      title_row + items
    else
      items
    end
  end
end

format :html do
  view :card_list do
    with_results do
      search_result_list "search-result-list" do |item_card|
        card_list_item item_card
      end
    end
  end

  view :select_item, cache: :never do
    wrap do
      haml :select_item
    end
  end

  before :select_item do
    class_up "card-slot", "_filter-result-slot"
  end

  view :checkbox_list, cache: :never do
    with_results do
      search_result_list "_search-checkbox-list pr-2" do |item_card|
        checkbox_item item_card
      end
    end
  end

  view :no_search_results do
    wrap_with :div, "", class: "search-no-results"
  end

  private

  def card_list_item item_card
    nest_item item_card, size: voo.size do |rendered, item_view|
      %(<div class="search-result-item item-#{item_view}">#{rendered}</div>)
    end
  end

  def search_result_list klass
    with_paging do
      wrap_with :div, class: klass do
        search_with_params.map do |item_card|
          yield item_card
        end
      end
    end
  end

  def checkbox_item item_card
    subformat(item_card).wrap do
      haml :checkbox_item, unique_id: unique_id, item_card: item_card
    end
  end

  def closed_limit
    [search_params[:limit].to_i, Card.config.closed_search_limit].min
  end
end
