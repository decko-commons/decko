ACTS_PER_PAGE = 25

view :title do
  voo.title ||= "Recent Changes"
  super()
end

def recent_acts
  action_relation = qualifying_actions.where "card_acts.id = card_act_id"
  Act.where("EXISTS (#{action_relation.to_sql})").order id: :desc
end

def qualifying_actions
  Action.all_viewable.where "draft is not true"
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

format :json do
  def items_for_export
    card.item_cards limit: 20
  end
end
