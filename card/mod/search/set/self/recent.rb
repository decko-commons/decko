ACTS_PER_PAGE = 25

view :title do
  voo.title = "Recent Changes"
  super()
end

def recent_acts
  Act.all_viewable("draft is not true").order id: :desc
end

format :html do
  view :core do
    voo.hide :history_legend unless voo.main
    @acts_per_page = ACTS_PER_PAGE
    acts_layout card.recent_acts, :absolute
  end
end

format :rss do
  view :feed_item_description do
    render_blank
  end
end
