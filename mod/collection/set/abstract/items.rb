def recursable_items?
  true
end

# @return [Array] list of integers (card ids of items)
# @param args [Hash] see #item_names
def item_ids args={}
  item_names(args).map(&:card_id).compact
end

# #item_name, #item_id, and #item_card each return a single item, rather than an array.
%i[name id card].each do |obj|
  define_method "item_#{obj}" do |args={}|
    send("item_#{obj}s", args.merge(limit: 1)).first
  end
end

# for override, eg by json
def item_value item_name
  item_name
end

def item_type_id
  opt = options_card
  # FIXME: need better recursion prevention
  return unless opt && opt != self

  opt.item_type_id
end


