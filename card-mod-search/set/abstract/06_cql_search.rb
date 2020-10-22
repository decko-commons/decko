include_set Abstract::Search

module SearchCQL
  def search args={}
    with_skipping args do
      query = fetch_query(args)
      # forces explicit limiting
      # can be 0 or less to force no limit
      raise "OH NO.. no limit" unless query.mods[:limit]
      query.run
    end
  end

  # for override, eg when required subqueries are known to be missing
  def skip_search?
    false
  end

  def with_skipping args
    skip_search? ? skipped_search_result(args) : yield
  end

  def skipped_search_result args={}
    args[:return] == :count ? 0 : []
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

  def query_args args={}
    cql_hash.merge args
  end
end

include SearchCQL

def cql_hash
  cache_query? ? (@cql_hash ||= cql_content) : cql_content
end

# override this to define search
def cql_content
  @cql_content = nil unless cache_query?
  @cql_content ||= begin
    query = content
    query = query.is_a?(Hash) ? query : parse_json_query(query)
    query.symbolize_keys
  end
end

def item_type
  type = cql_hash[:type]
  return if type.is_a?(Array) || type.is_a?(Hash)
  type
end

private

def parse_json_query query
  empty_query_error! if query.empty?
  JSON.parse query
rescue JSON::ParserError
  raise Error::BadQuery, "Invalid JSON search query: #{query}"
end

def empty_query_error!
  raise Error::BadQuery, "can't run search with empty content"
end

format do
  include SearchCQL

  # FIXME: move name delegation to more appropriate place
  delegate :cql_content, :name, to: :card

  def cql_hash
    @cql_hash = nil unless cache_query?
    @cql_hash ||= cql_content.merge filter_and_sort_cql
  end

  def default_limit
    card_content_limit || super
  end

  def card_content_limit
    card.cql_hash&.dig :limit
  end

  def item_view_from_query
    query_with_params.statement[:item]
  end

  def query_with_params
    @query_with_params ||= card.fetch_query search_params
  end

  def limit
    query_with_params.limit
  end
end

format :html do
  def default_limit
    card_content_limit || super
  end
end
