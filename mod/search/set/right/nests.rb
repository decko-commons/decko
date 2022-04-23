include_set Abstract::VirtualSearch

def cql_content
  { nested_by: "_left", sort: "name" }
end

def raw_help_text
  "Cards that {{_left|name}} includes."
end
