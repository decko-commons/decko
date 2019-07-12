include_set Abstract::Pointer

event :validate_listed_by_name, :validate, on: :save, changing: :name do
  if !junction? || !right || right.type_id != CardtypeID
    errors.add :name, tr(:cardtype_right)
  end
end

event :validate_listed_by_content, :validate,
      on: :save, changing: :content do
  item_cards(content: content).each do |item_card|
    next unless item_card.type_id != right.id
    errors.add(
      :content,
      "#{item_card.name} has wrong cardtype; " \
      "only cards of type #{name.right} are allowed"
    )
  end
end

event :update_content_in_list_cards, :prepare_to_validate,
      on: :save, changing: :content do
  return unless db_content.present?
  new_items = item_keys(content: db_content)
  old_items = item_keys(content: old_content)
  remove_items(old_items - new_items)
  add_items(new_items - old_items)
end

def old_content
  db_content_before_act.present? ? db_content_before_act : content_cache.read(key)
end

def remove_items items
  items.each do |item|
    next unless (lc = list_card item)
    lc.drop_item name.left
    subcards.add lc
  end
end

def add_items items
  items.each do |item|
    if (lc = list_card(item))
      lc.add_item name.left
      subcards.add lc
    else
      subcards.add(name: "#{Card[item].name}+#{left.type_name}",
                   type: "list",
                   content: "[[#{name.left}]]")
    end
  end
end

def content_cache
  Card::Cache[Card::Set::Type::MirrorList]
end

def content
  content_cache.fetch(key) do
    generate_content
  end
end

def generate_content
  listed_by.map do |item|
    "[[%s]]" % item.to_name.left
  end.join "\n"
end

def listed_by
  Card.search(
    { type_id: Card::MirroredListID, right: trunk.type_name,
      left: { type: name.tag }, refer_to: name.trunk, return: :name },
    "all cards listed by #{name}"
  )
end

def update_cached_list
  if trunk
    Card::Cache[Card::Set::Type::MirrorList].write key, generate_content
  else
    Card::Cache[Card::Set::Type::MirrorList].delete key
  end
end

def list_card item
  Card.fetch item, left.type_name
end

def unfilled?
  false
end
