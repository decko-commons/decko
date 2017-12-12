
def sort_hash
  { sort: (Env.params[:sort].present? ? Env.params[:sort] : default_sort_option) }
end

def filter_param field
  filter_hash[field.to_sym]
end

def sort_param
  Env.params[:sort] || default_sort_option
end

def filter_keys_with_values
  (filter_keys + advanced_filter_keys).map do |key|
    values = filter_param(key)
    next unless values.present?
    [key, values]
  end.compact
end

def offset
  param_to_i :offset, 0
end

format do
  delegate :filter_hash, :sort_hash, :filter_param, :sort_param,
           :all_filter_keys, to: :card
end

format :html do
  def extra_paging_path_args
    { filter: filter_hash }.merge sort_hash
  end

  def filter_active?
    filter_hash.present?
  end
end
