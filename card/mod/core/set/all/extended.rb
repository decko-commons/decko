
def extended_item_cards context=nil
  context = (context ? context.name : name)
  args = { limit: "" }
  items = item_cards(args.merge(context: context))
  extended_list = []
  already_extended = ::Set.new # avoid loops

  until items.empty?
    item = items.shift
    next if already_extended.include? item
    already_extended << item
    if item.collection?
      # keep items in order
      items.unshift(*item.item_cards)
    else  # no further level of items
      extended_list << item
    end
  end
  extended_list
end

def extended_item_contents context=nil
  extended_item_cards(context).map(&:item_names).flatten
end

def extended_list context=nil
  context = (context ? context.name : name)
  args = { limit: "" }
  item_cards(args.merge(context: context)).map do |x|
    x.item_cards(args)
  end.flatten.map do |x|
    x.item_cards(args)
  end.flatten.map do |y|
    y.item_names(args)
  end.flatten
  # this could go on and on.  more elegant to recurse until you don't have
  # a collection
end
