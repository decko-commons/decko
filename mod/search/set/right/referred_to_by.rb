include_set Abstract::VirtualSearch

assign_type :search_type

def cql_content
  { refer_to: "_left", sort_by: "name" }
end

def raw_help_text
  "Cards that refer to {{_left|name}}."
end
