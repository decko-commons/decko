@@options = { compound_only: true }

def label _name
  'All "+*" cards'
end

def short_label _name
  'all "+*" cards'
end

def prototype_args _anchor
  { name: "*dummy+*dummy" }
end

def pattern_applies? card
  card.name.rstar?
end
