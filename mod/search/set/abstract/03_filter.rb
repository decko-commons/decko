# include_set Abstract::Utility

format do
  def filter_class
    Card::FilterQuery
  end

  def filter_keys
    [:name]
  end

  def filter_keys_from_params
    filter_hash.keys.map(&:to_sym) - [:not_ids]
  end

  def sort_options
    { "Alphabetical": :name, "Recently Added": :create }
  end
end

format :html do
  view :filtered_content, template: :haml, wrap: :slot

  view :filtered_results do
    class_up "card-slot", "_filter-result-slot"
    wrap { render_core }
  end

  view :selectable_filtered_content, template: :haml, cache: :never
end
