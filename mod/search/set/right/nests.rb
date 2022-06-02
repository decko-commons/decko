include_set Abstract::VirtualSearch

assign_type :search_type

def cql_content
  { nested_by: "_left", sort_by: "name" }
end

def raw_help_text
  "Cards that {{_left|name}} includes."
end
