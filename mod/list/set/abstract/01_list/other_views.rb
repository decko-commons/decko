# BASE views

format do
  def default_limit
    20
  end

  view :core do
    pointer_items.join ", "
  end

  def pointer_items args={}
    page_args = args.extract! :limit, :offset
    listing card.item_cards(page_args), args
  end
end

# JavaScript views

format :csv do
  view :core do
    pointer_items.join ";"
  end
end

format :js do
  view :core do
    nest_item_array.join "\n\n"
  end
end

# Data views

format :data do
  view :core do
    card.known? ? render_content : []
  end

  view :content do
    nest_item_array
  end
end

# JSON views

format :json do
  view :content do
    card.item_names
  end

  def item_cards
    card.item_cards
  end

  def max_depth
    params[:max_depth] || 1
  end

  view :links do
    []
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

  view :content do
    nest_item_array.join "\n\n"
  end
end

# RSS views

format :rss do
  def raw_feed_items
    @raw_feed_items ||= card.item_cards(limit: limit, offset: offset)
  end
end
