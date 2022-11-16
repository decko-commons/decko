@@options = { compound_only: true }

def label _name
  "All rule cards"
end

def short_label _name
  "all rule cards"
end

def prototype_args _anchor
  { name: "*all+*create" }
end

def pattern_applies? card
  card.rule?
end
