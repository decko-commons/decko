ACTS_PER_PAGE = 25
MAX_ACTS_TO_SCAN = 10_000

view :title do
  voo.title ||= "Recent Changes"
  super()
end

# FIXME - this should not be a CQL search card
def cql_content
  {}
end

def recent_acts
  limiting_scan do
    Act.joins(ar_actions: :ar_card).distinct
       .where(Query::CardQuery.viewable_sql)
       .where("draft is not true")
       .order id: :desc
  end
end

def limiting_scan
  min_id = Card::Act.maximum(:id) - MAX_ACTS_TO_SCAN
  min_id.positive? ? yield.where("card_acts.id > #{min_id}") : yield
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

# *Strat 1: WHERE EXISTS*
# ~~~~~~~~~~~~~~~~~~~~~~~
# SELECT `card_acts`.* FROM `card_acts` WHERE EXISTS (
#   SELECT `card_actions`.*
#   FROM `card_actions`
#   INNER JOIN `cards` ON `cards`.`id` = `card_actions`.`card_id`
#   WHERE (draft is not true)
#   AND (card_acts.id = card_act_id)
# ) ORDER BY `card_acts`.`id` DESC LIMIT 20;
#
#
# *Strat 2: INNER JOIN*
# ~~~~~~~~~~~~~~~~~~~~~
# SELECT DISTINCT `card_acts`.* FROM `card_acts`
# JOIN `card_actions` ON card_acts.id = card_act_id
# JOIN `cards` ON `cards`.`id` = `card_actions`.`card_id`
# WHERE (draft is not true)
# ORDER BY `card_acts`.`id` DESC LIMIT 20;

# 11:33
# first run times:
# mysql 5.7:
# - strat 1: 0.22 sec (possibly in cache already?)
# - strat 2: 3min 17 sec
# mysql 8.0
# - strat 1: 2min 1 sec
# - strat 2: 0.01 sec
