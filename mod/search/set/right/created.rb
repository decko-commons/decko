include_set Abstract::VirtualSearch

assign_type :search_type

def cql_content
  { created_by: "_left", sort_by: "create", dir: "desc" }
end

def raw_help_text
  "Cards created by {{_left|name}}."
end
