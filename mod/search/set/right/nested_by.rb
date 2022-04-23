include_set Abstract::VirtualSearch

def raw_help_text
  "Cards that nest {{_left|name}}."
end

def cql_content
  { nest: "_left", sort: "name" }
end
