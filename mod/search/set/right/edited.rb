include_set Abstract::VirtualSearch

assign_type :search_type

def cql_content
  { edited_by: "_left", sort_by: "name" }
end

def raw_help_text
  "Cards edited by {{_left|name}}."
end
