include_set Abstract::VirtualSearch

assign_type :search_type

def cql_content
  { linked_to_by: "_left", sort_by: "name" }
end

def raw_help_text
  "Cards that <em>{{_left|name}}</em> links to."
end
