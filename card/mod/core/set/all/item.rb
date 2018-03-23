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

def include_item? item
  key = item.is_a?(Card) ? item.name.key : item.to_name.key
  item_names.map { |name| name.to_name.key }.member? key
end

def add_item item
  return if include_item? item
  self.content = "#{content}\n#{item}"
end

def drop_item item
  return unless include_item? item
  new_names = item_names.reject { |i| i == item }
  self.content = new_names.empty? ? "" : new_names.join("\n")
end

def insert_item index, name
  new_names = item_names
  new_names.delete name
  new_names.insert index, name
  self.content = new_names.join "\n"
end

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
    view = params[:item] || voo_items_view || default_item_view
    Card::View.canonicalize view
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
end
