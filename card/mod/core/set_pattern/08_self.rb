def label name
  %(The card "#{name}")
end

def short_label name
  name
end

def prototype_args anchor
  { name: anchor }
end

def anchor_name card
  card.name
end

def anchor_id card
  card.id
end
