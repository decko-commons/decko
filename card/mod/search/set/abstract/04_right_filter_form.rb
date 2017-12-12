# To be included in a field card to get a filter for the parent.
# The core view renders a filter for the left card.

include_set Set::Abstract::Filter

def virtual?
  true
end

format :html do
  def filter_action_path
    path mark: card.name.left, view: filter_view
  end

  view :core, cache: :never do
    filter_fields slot_selector: ".RIGHT-all_metric_value.filter_result-view"
  end

  def filter_view
    :filter_result
  end
end
