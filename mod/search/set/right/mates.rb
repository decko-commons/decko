include_set Abstract::VirtualSearch,
            cql_content: { plus: "_left", sort_by: "name" },
            raw_help_text:
              'If there is a card named "X+{{_left|name}}", ' \
              "then X is a mate of {{_left|name}}."
