include_set Abstract::Search

def cql_hash
  cache_query? ? (@cql_hash ||= cql_content) : cql_content
end

# override this to define search
def cql_content
  query = content
  query = query.is_a?(Hash) ? query : parse_json_cql(query)
  query.symbolize_keys
end

def item_type
  type = cql_hash[:type]
  return if type.is_a?(Array) || type.is_a?(Hash)

  type
end

# for override, eg when required subqueries are known to be missing
def skip_search?
  false
end

def cache_query?
  true
end

def parse_json_cql query
  empty_query_error! if query.empty?
  JSON.parse query
rescue JSON::ParserError
  raise Error::BadQuery, "Invalid JSON search query: #{query}"
end

def empty_query_error!
  raise Error::BadQuery, "can't run search with empty content"
end

# These search methods are shared by card and format
def search args={}
  with_skipping args do
    query = fetch_query(args)
    # forces explicit limiting
    # can be 0 or less to force no limit
    raise "OH NO.. no limit" unless query.mods[:limit]

    query.run
  end
end

def with_skipping args
  return yield unless skip_search?

  args[:return] == :count ? 0 : []
end

def fetch_query args={}
  @query = nil unless cache_query?
  @query ||= {}
  @query[args.to_s] ||= query(args.clone) # cache query
end

def query args={}
  Query.new standardized_query_args(args), name
end

def standardized_query_args args
  args = cql_hash.merge args.symbolize_keys
  args[:context] ||= name
  args
end

format do
  def search_params
    super.merge filter_and_sort_cql
  end

  def default_limit
    card_content_limit || super
  end

  def card_content_limit
    card.cql_hash&.dig :limit
  end
end

format :html do
  def default_limit
    card_content_limit || super
  end
end
