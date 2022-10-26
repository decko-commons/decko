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

def first_id
  first_card&.id
end

def item_cards args={}
  standard_item_cards args
end

def item_strings args={}
  items = raw_item_strings(args[:content] || content)
  return items unless args.present?

  filtered_items items, limit: args[:limit], offset: args[:offset]
end

def raw_item_strings content
  content.to_s.split(/\n+/).map { |i| strip_item i }
end

# @return [Array] list of Card objects
# @param args [Hash] see #item_names for additional options
# @option args [String] :complete keyword to use in searching among items
# @option args [True/False] :known_only if true, return only known cards
# @option args [String] :type name of type to be used for unknown cards
def standard_item_cards args={}
  return item_cards_search(args) if args[:complete]
  return known_item_cards(args) if args[:known_only]

  all_item_cards args
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


format do
  view :count do
    card.item_names.size
  end

  def nest_item cardish, options={}, &block
    options = item_view_options options
    options[:nest_name] = Card::Name[cardish].s
    nest cardish, options, &block
  end

  def item_links args={}
    card.item_cards(args).map do |item_card|
      nest_item item_card, view: :link
    end
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

def fetch_item_card name, args={}
  Card.fetch name, new: new_unknown_item_args(args)
end

def new_unknown_item_args args
  itype = args[:type] || item_type_name
  itype ? { type: itype } : {}
end

def filtered_items items, limit: 0, offset: 0
  limit = limit.to_i
  offset = offset.to_i
  return items unless limit.positive? || offset.positive?

  items[offset, (limit.zero? ? items.size : limit)] || []
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