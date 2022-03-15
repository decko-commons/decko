def extended_item_cards context=nil
  items = item_cards limit: "", context: (context || self).name
  list = []
  book = ::Set.new # avoid loops
  extend_item_list items, list, book until items.empty?
  list
end

def extended_item_contents context=nil
  extended_item_cards(context).map(&:item_names).flatten
end

format do
  delegate :extended_item_contents, to: :card
end

private

def extend_item_list items, list, book
  item = items.shift
  return if already_extended?(item, book)

  if item.collection?
    # keep items in order
    items.unshift(*item.item_cards.compact)
  else  # no further level of items
    list << item
  end
end

def already_extended? item, book
  return true if book.include? item

  book << item
  false
end

# def extended_list context=nil
#   context = (context ? context.name : name)
#   args = { limit: "" }
#   item_cards(args.merge(context: context)).map do |x|
#     x.item_cards(args)
#   end.flatten.map do |x|
#     x.item_cards(args)
#   end.flatten.map do |y|
#     y.item_names(args)
#   end.flatten
#   # this could go on and on.  more elegant to recurse until you don't have
#   # a collection
# end
