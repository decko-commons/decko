include_set Abstract::VirtualSearch

def cql_content
  { plus: "_left", sort: "name" }
end

def raw_help_text
  "If there is a card named \"X+{{_left|name}}\", then X is a mate of {{_left|name}}."
end
