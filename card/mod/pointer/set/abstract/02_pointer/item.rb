event :add_and_drop_items, :prepare_to_validate, on: :save do
  adds = Env.params["add_item"]
  drops = Env.params["drop_item"]
  Array.wrap(adds).each { |i| add_item i } if adds
  Array.wrap(drops).each { |i| drop_item i } if drops
end

event :insert_item_event, :prepare_to_validate,
      on: :save, when: proc { Env.params["insert_item"] } do
  index = Env.params["item_index"] || 0
  insert_item index.to_i, Env.params["insert_item"]
end

def items= array
  self.content = ""
  array.each { |i| self << i }
  save!
end

def << item
  add_item Card::Name[item]
end

def add_item name, allow_duplicates=false
  return if !allow_duplicates && include_item?(name)
  self.content = "[[#{(item_names << name).reject(&:blank?) * "]]\n[["}]]"
end

def add_item! name
  add_item(name) && save!
end

def drop_item name
  return unless include_item? name
  key = name.to_name.key
  new_names = item_names.reject { |n| n.to_name.key == key }
  self.content = new_names.empty? ? "" : "[[#{new_names * "]]\n[["}]]"
end

def drop_item! name
  drop_item name
  save!
end

def insert_item index, name
  new_names = item_names
  new_names.delete name
  new_names.insert index, name
  self.content = new_names.map { |new_name| "[[#{new_name}]]" }.join "\n"
end

def insert_item! index, name
  insert_item index, name
  save!
end
