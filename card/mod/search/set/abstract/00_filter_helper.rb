# TODO: move sort/filter handling out of card and into base format
# sorting and filtering is about viewing the data, not altering the data itself.

def sort_hash
  sort_param.present? ? { sort: sort_param } : {}
end

def filter_param field
  filter_hash[field.to_sym]
end

# FIXME: it is inconsistent that #sort_hash has :sort as the key, but
# #filter_hash is the _value_ of the hash with :filter as the key.
def filter_hash
  @filter_hash ||= begin
    filter = Env.params[:filter] || default_filter_hash
    filter.try(:to_unsafe_h) || filter.clone
  end
end

def sort_param
  safe_sql_param :sort
end

def safe_sql_param key
  param = Env.params[key]
  param.blank? ? nil : Card::Query.safe_sql(param)
end

def filter_keys_with_values
  filter_keys.map do |key|
    values = filter_param(key)
    values.present? ? [key, values] : next
  end.compact
end

# initial values for filtered search
def default_filter_hash
  {}
end

def offset
  param_to_i :offset, 0
end

format do
  delegate :filter_hash, :sort_hash, :filter_param, :sort_param,
           :all_filter_keys, to: :card

  def extra_paging_path_args
    super.merge filter_and_sort_hash
  end

  def filter_and_sort_hash
    sort_hash.merge filter: filter_hash
  end
end
