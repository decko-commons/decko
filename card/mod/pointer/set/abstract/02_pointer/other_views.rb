# BASE views

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

  view :core do
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

# JavaScript views

format :js do
  view :core do
    nest_item_array.join "\n\n"
  end
end

# Data views

format :data do
  view :core, cache: :never do
    nest_item_array
  end
end

# JSON views

format :json do
  def max_depth
    params[:max_depth] || 1
  end

  def items_for_export
    card.item_cards
  end

  def essentials
    return {} if depth > max_depth
    card.item_cards.map do |item|
      nest item, view: :essentials
    end
  end
end

# CSS views

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

# RSS views

format :rss do
  def raw_feed_items
    @raw_feed_items ||= card.item_cards(limit: limit, offset: offset)
  end
end
