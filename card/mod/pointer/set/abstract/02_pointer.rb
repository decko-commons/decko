include_set Abstract::Paging

stage_method :changed_item_names do
  dropped_item_names + added_item_names
end

stage_method :dropped_item_names do
  old_items = item_names content: db_content_before_act
  old_items - item_names
end

stage_method :added_item_names do
  old_items = item_names content: db_content_before_act
  item_names - old_items
end

stage_method :changed_item_cards do
  item_cards content: changed_item_names
end

format do
  def default_limit
    20
  end

  def item_links args={}
    card.item_cards(args).map do |item_card|
      subformat(item_card).render_link
    end
  end

  def wrap_item item, _args={}
    item # no wrap in base
  end

  def nest_item_array
    card.item_cards.map do |item|
      nest_item item
    end
  end

  view :core do |_args|
    pointer_items.join ", "
  end

  def pointer_items args={}
    page_args = args.extract! :limit, :offset
    card.item_cards(page_args).map do |item_card|
      nest_item item_card, args do |rendered, item_view|
        wrap_item rendered, item_view
      end
    end
  end
end

format :html do
  view :core do
    with_paging do |paging_args|
      wrap_with :div, pointer_items(paging_args.extract!(:limit, :offset)),
                class: "pointer-list"
    end
  end

  view :closed_content do
    item_view = implicit_item_view
    item_view = item_view == "name" ? "name" : "link"
    wrap_with :div, class: "pointer-list" do
      # unlikely that more than 100 items fit in closed content
      # even if every item is only one character
      pointer_items(view: item_view, limit: 100, offset: 0).join ", "
    end
  end

  def wrap_item rendered, item_view
    %(<div class="pointer-item item-#{item_view}">#{rendered}</div>)
  end
end

format :css do
  # generalize to all collections?
  def default_item_view
    :content
  end

  view :titled do
    %(#{major_comment "STYLE GROUP: \"#{card.name}\"", '='}#{_render_core})
  end

  view :core do
    voo.items[:view] = params[:item] if params[:item]
    nest_item_array.join "\n\n"
  end

  view :content, :core
end

format :js do
  view :core do
    nest_item_array.join "\n\n"
  end
end

format :data do
  view :core, cache: :never do
    nest_item_array
  end
end

format :rss do
  def raw_feed_items
    @raw_feed_items ||= card.item_cards(limit: limit, offset: offset)
  end
end

format :json do
  def max_depth
    params[:max_depth] || 1
  end

  view :export_items do |args|
    item_args = args.merge view: :export
    card.known_item_cards.map do |item_card|
      nest_item item_card, item_args
    end.flatten.reject(&:blank?)
  end

  def essentials
    return if @depth > max_depth
    card.item_cards.map do |item|
      nest item, view: :essentials
    end
  end
end

# If a card's type and content are updated in the same action, the new module
# will override the old module's events and functions. But this event is only
# on pointers -- other type cards do not have this event,
# Therefore if something is changed from a pointer and its content is changed
# in the same action, this event will be run and will treat the content like
# it' still pointer content.  The "when" clause helps with that (but is a hack)
event :standardize_items, :prepare_to_validate,
      on: :save, changed: :content,
      when: proc { |c| c.type_id == Card::PointerID } do
  self.content = item_names(context: :raw).map do |name|
    "[[#{name}]]"
  end.join "\n"
end

def diff_args
  { diff_format: :pointer }
end

def item_cards args={}
  if args[:complete]
    query = args.reverse_merge referred_to_by: name, limit: 0
    Card::Query.run query
  elsif args[:known_only]
    known_item_cards args
  else
    fetch_or_initialize_item_cards args
  end
end

def known_item_cards args={}
  item_names(args).map do |name|
    Card.fetch name
  end.compact
end

def fetch_or_initialize_item_cards args
  itype = args[:type] || item_type
  new_args = itype ? { type: itype } : {}
  item_names(args).map do |name|
    Card.fetch name, new: new_args
  end
end

def item args={}
  item_names(args).first
end

def item_names args={}
  context = args[:context] || context_card.cardname
  content = args[:content] || raw_content
  raw_items = content.to_s.split(/\n+/)
  if args[:limit].present? && args[:limit].to_i > 0
    offset = args[:offset] || 0
    raw_items = raw_items[offset, args[:limit].to_i] || []
  end
  raw_items.map do |line|
    item_name = line.gsub(/\[\[|\]\]/, "").strip
    if context == :raw
      item_name
    else
      item_name.to_name.to_absolute context
    end
  end
end

def item_ids args={}
  item_names(args).map do |name|
    Card.fetch_id name
  end.compact
end

def item_type
  opt = options_rule_card
  if !opt || opt == self # fixme, need better recursion prevention
    nil
  else
    opt.item_type
  end
end

def options_rule_card
  rule_card :options
end
