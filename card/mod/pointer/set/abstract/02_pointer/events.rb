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

# If a card's type and content are updated in the same action, the new module
# will override the old module's events and functions. But this event is only
# on pointers -- other type cards do not have this event,
# Therefore if something is changed from a pointer and its content is changed
# in the same action, this event will be run and will treat the content like
# it' still pointer content.  The "when" clause helps with that (but is a hack)
event :standardize_items, :prepare_to_validate,
      on: :save, changed: :content, when: :still_pointer? do
  self.content = item_names(context: :raw).map do |name|
    "[[#{name}]]"
  end.join "\n"
end

def still_pointer?
  type_id == Card::PointerID
end

stage_method :changed_item_names do
  dropped_item_names + added_item_names
end

stage_method :dropped_item_names do
  return [] unless (old_content = db_content_before_act)

  old_items = item_names content: old_content
  old_items - item_names
end

stage_method :added_item_names do
  return item_names unless (old_content = db_content_before_act)

  old_items = item_names content: old_content
  item_names - old_items
end

stage_method :changed_item_cards do
  dropped_item_cards + added_item_cards
end

stage_method :dropped_item_cards do
  return [] unless db_content_before_act

  item_cards content: dropped_item_names
end

stage_method :added_item_cards do
  return item_cards unless db_content_before_act

  item_cards content: added_item_names
end

# TODO: refactor. many of the above could be written more elegantly with improved
# handling of :content in item_names. If content is nil here, we would expect an
# empty set of cards, but in fact we get items based on self.content.
