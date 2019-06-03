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

  view :filtered_content, template: :haml, wrap: :slot
end
