include_set Abstract::VirtualSearch

assign_type :search_type

def cql_content
  { "found_by": "_left", sort: "update" }
end
