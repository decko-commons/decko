# set card content based on array and save card
# @param array [Array] list of strings/names (Cardish)
def items= array
  self.content = array
  save!
end

# append item to list (does not save)
# @param cardish [Cardish]
def << cardish
  add_item cardish
end

# append item to list (does not save)
# @param cardish [String, Card::Name] item name
# @param allow_duplicates [True/False] permit duplicate items (default is False)
def add_item cardish, allow_duplicates=false
  return if !allow_duplicates && include_item?(cardish)

  self.content = (item_strings << cardish)
end

# append item to list and save card
# @param name [String, Card::Name] item name
def add_item! name
  add_item(name) && save!
end

# remove item from list
# @param cardish [String, Card::Name] item to drop
def drop_item cardish
  item_name = cardish.cardname
  self.content = (item_names.reject { |i| i == item_name })
end

# remove item from list and save card
# @param cardish [String, Card::Name] item to drop
def drop_item! cardish
  drop_item cardish
  save!
end

# insert item into list at specified location
# @param index [Integer] Array index in which to insert item (0 is first)
# @param name [String, Card::Name] item name
def insert_item index, name
  new_names = item_names
  new_names.delete name
  new_names.insert index, name
  self.content = new_names
end

# insert item into list at specified location and save
# @param index [Integer] Array index in which to insert item (0 is first)
# @param name [String, Card::Name] item name
def insert_item! index, name
  insert_item index, name
  save!
end

def replace_item old, new
  return unless include_item? old

  drop_item old
  add_item new
end

def items_content array
  standardized_items(array).to_pointer_content
end

def standardized_items array
  array.map { |i| standardize_item i }.reject(&:blank?)
end

def standardize_item item
  Card::Name[item]
rescue Card::Error::NotFound
  item
end
