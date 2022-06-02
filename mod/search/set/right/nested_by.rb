include_set Abstract::VirtualSearch

assign_type :search_type

def raw_help_text
  "Cards that nest {{_left|name}}."
end

def cql_content
  { nest: "_left", sort_by: "name" }
end
