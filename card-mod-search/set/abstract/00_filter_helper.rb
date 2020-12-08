format do
  def filter_param field
    filter_hash[field.to_sym]
  end

  def filter_hash
    @filter_hash ||= filter_hash_from_params || default_filter_hash
  end

  def filter_hash_from_params
    return unless Env.params[:filter].present?

    Env.hash(Env.params[:filter]).deep_symbolize_keys
  end

  def sort_param
    @sort_param ||= safe_sql_param :sort
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

  def extra_paging_path_args
    super.merge filter_and_sort_hash
  end

  def filter_and_sort_hash
    { filter: filter_hash }.tap do |hash|
      hash[:sort] = sort_param if sort_param
    end
  end
end
