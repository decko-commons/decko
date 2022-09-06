assign_type :search_type

def virtual?
  new?
end

def cql_content
  { member:  "_left" }
end
