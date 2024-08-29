include_set Abstract::Paging

AUTOCOMPLETE_LIMIT = 8 # number of name suggestions for autocomplete text fields

def search _args={}
  raise Error, "search not overridden"
end

def cached_search args={}
  @search_results ||= {}
  @search_results[args.to_s] ||= search args
end

def returning item, args
  args[:return] = item
  yield
end

def item_cards args={}
  args[:limit] ||= 0
  returning(:card, args) { search args }
end

def item_names args={}
  args[:limit] ||= 0
  returning(:name, args) { search args }
end

def item_ids args={}
  args[:limit] ||= 0
  returning(:id, args) { search args }
end

def count args={}
  args[:offset] = 0
  args[:limit] = 0
  returning(:count, args) { search args }
end

# for override
# def item_type_id
#   nil
# end

def each_item_name_with_options _content=nil
  options = {}
  item = fetch_query.statement[:view]
  options[:view] = item if item
  item_names.each do |name|
    yield name, options
  end
end

format do
  view(:count, cache: :never) { super() }

  def search_with_params
    @search_with_params ||= search_with_rescue search_params
  end

  def count_with_params
    @count_with_params ||= search_with_rescue search_params.merge(return: :count)
  end

  def search_with_rescue query_args
    rescuing_bad_query query_args do
      card.cached_search query_args
    end
  end

  def rescuing_bad_query query_args
    yield
  rescue Error::BadQuery => e
    Rails.logger.info "BadQuery: #{query_args}"
    e
  end

  def implicit_item_view
    view = voo_items_view || default_item_view
    Card::View.normalize view
  end
end

format :html do
  view(:count, cache: :never) { super() }
end
