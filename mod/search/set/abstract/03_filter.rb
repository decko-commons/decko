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
    wrap do
      [
        render_filtered_results_header,
        render_core,
        render_filtered_results_footer
      ]
    end
  end

  view :filtered_results_header, template: :haml
  view :open_filter_button, template: :haml
  view :selectable_filtered_content, template: :haml, cache: :never

  # for override
  view(:filtered_results_footer) { "" }

  def offcanvas_filter_id
    "#{card.name.safe_key}-offCanvasFilters"
  end
end
