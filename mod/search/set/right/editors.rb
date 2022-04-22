include_set Abstract::VirtualSearch

def cql_content
  { editor_of: "_left", sort: "name" }
end

def raw_help_text
  "Users who have edited {{_left|name}}."
end
