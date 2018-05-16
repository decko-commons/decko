@@options = {
  junction_only: true,
  assigns_type: true,
  anchor_parts_count: 2
}

def label name
  %(All "+%s" cards on "%s" cards) % label_parts(name)
end

def short_label name
  %(all "+%s" on "%ss") % label_parts(name)
end

def label_parts name
  name = name.to_name
  [name.tag, name.left]
end

def prototype_args anchor
  {
    name: "+#{anchor.tag}",
    supercard: Card.new(name: "*dummy", type: anchor.trunk_name)
  }
end

def anchor_name card
  type_name = card.left(new:{})&.type_name || Card.default_type_id.cardname
  "#{type_name}+#{card.name.tag}"
end
