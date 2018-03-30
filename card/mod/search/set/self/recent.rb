ACTS_PER_PAGE = 25

view :title do
  voo.title = "Recent Changes"
  super()
end

def recent_acts
  Act.all_viewable.order(id: :desc)
end

format :html do
  view :core do
    voo.hide :history_legend unless voo.main
    acts_layout card.recent_acts, :absolute, ACTS_PER_PAGE
  end
end

format :rss do
  view :feed_item_description do
    render_blank
  end
end
