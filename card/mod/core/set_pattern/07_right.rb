@@options = {
  junction_only: true,
  assigns_type: true
}

def label name
  %(All "+#{name}" cards)
end

def short_label name
  %(all "+#{name}s")
end

def prototype_args anchor
  { name: "*dummy+#{anchor}" }
end

def anchor_name card
  card.name.tag
end
