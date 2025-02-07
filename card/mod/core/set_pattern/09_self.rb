def label name
  %(The card "#{name}")
end

def short_label name
  name
end

def generic_label
  "a single card"
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

def anchor_parts_count anchor_name=nil
  @anchor_parts_count ||= anchor_name&.part_names&.size || 1
end
