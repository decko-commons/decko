def recursed_item_cards context=nil
  list = []
  book = ::Set.new # avoid loops
  items =
    recursable_items? ? item_cards(limit: "", context: context&.name || name) : [self]
  recurse_item_list items, list, book until items.empty?
  list
end

def recursed_item_contents context=nil
  recursed_item_cards(context).map(&:item_names).flatten
end

def recursable_items?
  false
end

format do
  delegate :recursed_item_contents, to: :card
end

private

def recurse_item_list items, list, book
  item = items.shift
  return if already_recursed?(item, book)

  if item.recursable_items?
    # keep items in order
    items.unshift(*item.item_cards.compact)
  else  # no further level of items
    list << item
  end
end

def already_recursed? item, book
  return true if book.include? item

  book << item
  false
end
