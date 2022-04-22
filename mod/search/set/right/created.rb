include_set Abstract::VirtualSearch

def cql_content
  { created_by: "_left", sort: "create", dir: "desc" }
end

def raw_help_text
  "Cards created by {{_left|name}}."
end
