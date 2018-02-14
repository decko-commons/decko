
def sort_hash
  { sort: sort_param }
end

def filter_param field
  filter_hash[field.to_sym]
end

def filter_hash
  @filter_hash ||= begin
    filter = Env.params[:filter]
    filter = filter.to_unsafe_h if filter&.respond_to?(:to_unsafe_h)
    filter.is_a?(Hash) ? filter : {}
  end
end

def sort_param
  Env.params[:sort] if Env.params[:sort].present?
end

def filter_keys_with_values
  (filter_keys + advanced_filter_keys).map do |key|
    values = filter_param(key)
    next unless values.present?
    [key, values]
  end.compact
end

def default_filter_option
  {}
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
