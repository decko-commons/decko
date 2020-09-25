def default_limit
  cql_limit = fetch_query.limit if respond_to?(:fetch_query)
  cql_limit || 50
end
