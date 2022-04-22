include_set Abstract::VirtualSearch

def cql_content
  { edited_by: "_left", sort: "name" }
end

def raw_help_text
  "Cards edited by {{_left|name}}."
end
