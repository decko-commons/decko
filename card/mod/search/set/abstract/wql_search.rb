include_set Abstract::Search

def search args={}
  query = fetch_query(args)
  # forces explicit limiting
  # can be 0 or less to force no limit
  raise "OH NO.. no limit" unless query.mods[:limit]
  query.run
end

def cache_query?
  true
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
  args = query_args(args).symbolize_keys
  args[:context] ||= name
  args
end

# override this to define search
def wql_hash
  @wql_hash = nil unless cache_query?
  @wql_hash ||= wql_from_content.merge filter_and_sort_wql
end

def wql_from_content
  @wql_from_content = nil unless cache_query?
  @wql_from_content ||= begin
    query = content
    query = query.is_a?(Hash) ? query : parse_json_query(query)
    query.symbolize_keys
  end
end

def query_args args={}
  wql_hash.merge args
end

def parse_json_query query
  empty_query_error! if query.empty?
  JSON.parse query
rescue
  raise Error::BadQuery, "Invalid JSON search query: #{query}"
end

def empty_query_error!
  raise Error::BadQuery,
        "Error in card '#{name}':can't run search with empty content"
end

format do
  def default_limit
    card_content_limit || super
  end

  def card_content_limit
    card.wql_hash[:limit]
  rescue
    nil
  end

  def query_with_params
    @query_with_params ||= card.fetch_query search_params
  end

  def limit
    query_with_params.limit
  end
end
