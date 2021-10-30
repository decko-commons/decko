event :add_and_drop_items, :prepare_to_validate, on: :save do
  adds = Env.params["add_item"]
  drops = Env.params["drop_item"]
  Array.wrap(adds).each { |i| add_item i } if adds
  Array.wrap(drops).each { |i| drop_item i } if drops
end

event :insert_item_event, :prepare_to_validate, on: :save, when: :item_to_insert do
  index = Env.params["item_index"] || 0
  insert_item index.to_i, item_to_insert
end

def item_to_insert
  Env.params["insert_item"]
end

def changed_item_names
  dropped_item_names + added_item_names
end

def dropped_item_names
  return item_names if trash
  return [] unless (old_content = db_content_before_act)

  old_items = item_names content: old_content
  old_items - item_names
end

def added_item_names
  return [] if trash
  return item_names unless (old_content = db_content_before_act)

  old_items = item_names content: old_content
  item_names - old_items
end

# TODO: refactor. many of the above could be written more elegantly with improved
# handling of :content in item_names. If content is nil here, we would expect an
# empty set of cards, but in fact we get items based on self.content.

def changed_item_cards
  dropped_item_cards + added_item_cards
end

def dropped_item_cards
  return [] unless db_content_before_act

  all_item_cards item_names: dropped_item_names
end

def added_item_cards
  return item_cards unless db_content_before_act

  all_item_cards item_names: added_item_names
end
