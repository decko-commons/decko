include_set Abstract::VirtualSearch

def cql_content
  { part: "_left", sort: "name" }
end

def raw_help_text
  "Cards formed by \"mating\" {{_left|name}} with another card. "\
  "eg: \"{{_left|name}}+mate\"."
end
