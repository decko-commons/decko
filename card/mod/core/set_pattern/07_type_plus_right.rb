@@options = {
  junction_only: true,
  assigns_type: true,
  anchor_parts_count: 2
}

def label name
  %(All "+#{name.to_name.tag}" cards on "#{name.to_name.left_name}" cards)
end

def prototype_args anchor
  {
    name: "+#{anchor.tag}",
    supercard: Card.new(name: "*dummy", type: anchor.trunk_name)
  }
end

def anchor_name card
  left = Card.fetch card.name.left, new: {}
  type_name = left&.type_name || Card.default_type_id.cardname
  "#{type_name}+#{card.name.tag}"
end

def follow_label name
  %(all "+#{name.to_name.tag}" on "#{name.to_name.left_name}s")
end
