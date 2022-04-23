include_set Abstract::VirtualSearch

def cql_content
  { linked_to_by: "_left", sort: "name" }
end

def raw_help_text
  "Cards that <em>{{_left|name}}</em> links to."
end
