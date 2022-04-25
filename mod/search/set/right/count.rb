assign_type :search_type

def virtual?
  new?
end

def cql_content
  { found_by: "_left", return: "count" }
end
