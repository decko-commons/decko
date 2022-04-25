include_set Abstract::VirtualSearch

assign_type :search_type

def cql_content
  { link_to: "_left", sort: "name" }
end

def raw_help_text
  "Cards that link to {{_left|name}}."
end
