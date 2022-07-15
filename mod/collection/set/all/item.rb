def item_names _args={}
  format._render_raw.split(/[,\n]/)
end

# FIXME: this is inconsistent with item_names
def item_cards _args={}
  [self]
end

# typically override EITHER #item_type_id OR #item_type_name
def item_type_id
  @item_type_id ||= no_item_type_recursion { item_type_name&.card_id }
end

def item_type_name
  @item_type_name ||= no_item_type_recursion { item_type_id&.cardname }
end

def item_type_card
  item_type_id&.card
end

def item_keys args={}
  item_names(args).map do |item|
    item.to_name.key
  end
end

def item_count args={}
  item_names(args).size
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

def include_item? item
  item_names.include? Card::Name[item]
end

def add_item item
  self.content = (item_strings << item) unless include_item? item
end

def drop_item item
  item = Card::Name[item]
  self.content = (item_names.reject { |i| i == item }) if include_item? item
end

def insert_item index, name
  new_names = item_names
  new_names.delete name
  new_names.insert index, name
  self.content = new_names
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

    type_name = card.item_type_name
    options[:type] = type_name if type_name
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

private

def no_item_type_recursion
  return nil if @item_type_lookup

  @item_type_lookup = true
  yield
end
