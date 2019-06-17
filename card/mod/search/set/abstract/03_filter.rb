include_set Abstract::Utility

def filter_class
  Card::FilterQuery
end

def filter_keys
  [:name]
end

def filter_keys_from_params
  filter_hash.keys.map(&:to_sym) - [:not_ids]
end

format :html do
  def sort_options
    { "Alphabetical": :name, "Recently Added": :create }
  end

  before :filtered_content do
    return if Env.params[:filter].present?
    # this sets the default filter search options to match the default filter UI,
    # which is managed by the filter_card
    @filter_hash = card.filter_card.default_filter_option
  end

  view :filtered_content, template: :haml, wrap: :slot
end
