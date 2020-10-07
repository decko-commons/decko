# ~~~~~~~~~~~~ READING ITEMS ~~~~~~~~~~~~

# While each of the three main methods for returning lists of items can handle arguments,
# they are most commonly used without them.

# @return [Array] list of Card::Name objects
# @param args [Hash]
# @option args [String] :content override card content
# @option args [String, Card::Name, Symbol] :context name in whose context relative items
#         will be interpreted. For example. +A in context of B is interpreted as B+A
#         context defaults to pointer card's name. If value is `:raw`, then name is not
#         contextualized
# @option args [String, Integer] :limit max number of cards to return
# @option args [String, Integer] :offset begin after the offset-th item
def item_names args={}
  context = args[:context]
  item_strings(args).map do |item|
    clean_item_name item, context
  end.compact
end

def first_name args={}
  item_names(args).first
end

def first_card args={}
  return unless (name = first_name)
  fetch_item_card name, args
end

def first_code
  first_card&.codename
end

# @return [Array] list of integers (card ids of items)
# @param args [Hash] see #item_names
def item_ids args={}
  item_names(args).map { |name| Card.fetch_id name }.compact
end

# @return [Array] list of Card objects
# @param args [Hash] see #item_names for additional options
# @option args [String] :complete keyword to use in searching among items
# @option args [True/False] :known_only if true, return only known cards
# @option args [String] :type name of type to be used for unknown cards
def item_cards args={}
  return item_cards_search(args) if args[:complete]
  return known_item_cards(args) if args[:known_only]
  all_item_cards args
end

# #item_name, #item_id, and #item_card each return a single item, rather than an array.
%i[name id card].each do |obj|
  define_method "item_#{obj}" do |args={}|
    send("item_#{obj}s", args.merge(limit: 1)).first
  end
end

# ~~~~~~~~~~~~ ALTERING ITEMS ~~~~~~~~~~~~

# set card content based on array and save card
# @param array [Array] list of strings/names (Cardish)
def items= array
  items_to_content array
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

  items = item_strings << cardish
  items_to_content items
end

# append item to list and save card
# @param name [String, Card::Name] item name
def add_item! name
  add_item(name) && save!
end

# remove item from list
# @param cardish [String, Card::Name] item to drop
def drop_item cardish
  drop_item_name = Card::Name[cardish]
  items_to_content(item_names.reject { |item_name| item_name == drop_item_name })
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
  items_to_content new_names
end

# insert item into list at specified location and save
# @param index [Integer] Array index in which to insert item (0 is first)
# @param name [String, Card::Name] item name
def insert_item! index, name
  insert_item index, name
  save!
end

# ~~~~~~~~~~~~ READING ITEM HELPERS ~~~~~~~~~~~~

# Warning: the following methods, while available for use, may be subject to change

# #item_cards helpers

def item_cards_search query
  Card::Query.run query.reverse_merge(referred_to_by: name, limit: 0)
end

def known_item_cards args={}
  item_names(args).map { |name| Card.fetch name }.compact
end

def all_item_cards args={}
  names = args[:item_names] || item_names(args)
  names.map { |name| fetch_item_card name, args }
end

# TODO: support type_code and type_id. (currently type)
# uses name, because its most common use is from CQL
def item_type
  opt = options_rule_card
  # FIXME: need better recursion prevention
  return if !opt || opt == self
  opt.item_type
end

def item_strings args={}
  items = raw_item_strings(args[:content] || content)
  return items unless args.present?

  filtered_items items, args.slice(:limit, :offset)
end

def raw_item_strings content
  content.to_s.split(/\n+/).map { |i| strip_item i }
end

private

def filtered_items items, limit: 0, offset: 0
  limit = limit.to_i
  offset = offset.to_i
  return items unless limit.positive? || offset.positive?

  items[offset, (limit.zero? ? items.size : limit)] || []
end

def fetch_item_card name, args={}
  Card.fetch name, new: new_unknown_item_args(args)
end

def new_unknown_item_args args
  itype = args[:type] || item_type
  itype ? { type: itype } : {}
end

def clean_item_name item, context
  item = item.to_name
  return item if context == :raw
  context ||= context_card.name
  item.absolute_name context
rescue Card::Error::NotFound
  # eg for invalid ids or codenames
  # "Invalid Item: #{item}".to_name
  nil
end

def strip_item item
  item.gsub(/\[\[|\]\]/, "").strip
end
