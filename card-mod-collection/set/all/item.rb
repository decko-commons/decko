def item_names _args={}
  format._render_raw.split(/[,\n]/)
end

def item_cards _args={} # FIXME: this is inconsistent with item_names
  [self]
end

def item_type
  nil
end

def item_keys args={}
  item_names(args).map do |item|
    item.to_name.key
  end
end

def item_count args={}
  item_names(args).size
end

def items_to_content array
  items = array.map { |i| standardize_item i }.reject(&:blank?)
  self.content = items.to_pointer_content
end

def standardize_item item
  Card::Name[item]
end

def include_item? item
  item_names.include? Card::Name[item]
end

def add_item item
  return if include_item? item
  items_to_content(items_strings << item)
end

def drop_item item
  item = Card::Name[item]
  return unless include_item? item
  items_to_content(item_names.reject { |i| i == item })
end

def insert_item index, name
  new_names = item_names
  new_names.delete name
  new_names.insert index, name
  items_to_content new_names
end

def replace_item old, new
  return unless include_item? old
  drop_item old
  add_item new
end

# I think the following should work as add_item...
#
def add_id id
  add_item "~#{id}"
end

def drop_id id
  drop_item "~#{id}"
end

def insert_id index, id
  insert_item index, "~#{id}"
end

format do
  def item_links _args={}
    raw(render_core).split(/[,\n]/)
  end

  def nest_item cardish, options={}, &block
    options = item_view_options options
    options[:nest_name] = Card::Name[cardish].s
    nest cardish, options, &block
  end

  def implicit_item_view
    view = voo_items_view || default_item_view
    Card::View.normalize view
  end

  def voo_items_view
    return unless voo && (items = voo.items)
    items[:view]
  end

  def default_item_view
    :name
  end

  def item_view_options new_options={}
    options = (voo.items || {}).clone
    options = options.merge new_options
    options[:view] ||= implicit_item_view
    determine_item_view_options_type options
    options
  end

  def determine_item_view_options_type options
    return if options[:type]
    type_from_rule = card.item_type
    options[:type] = type_from_rule if type_from_rule
  end

  def listing listing_cards, item_args={}
    listing_cards.map do |item_card|
      nest_item item_card, item_args do |rendered, item_view|
        wrap_item rendered, item_view
      end
    end
  end

  def wrap_item item, _args={}
    item # no wrap in base
  end
end

format :html do
  def wrap_item rendered, item_view
    %(<div class="item-#{item_view}">#{rendered}</div>)
  end
end
