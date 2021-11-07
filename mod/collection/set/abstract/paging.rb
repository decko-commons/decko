MAX_ANONYMOUS_SEARCH_PARAM = 1000

format do
  def limit
    @limit ||= contextual_param(:limit) || default_limit
  end

  def offset
    @offset ||= contextual_param(:offset) || 0
  end

  def search_with_params
    @search_with_params ||= card.item_names
  end

  def count_with_params
    @count_with_params ||= card.item_names.count
  end

  def total_pages
    return 1 if limit.zero?

    ((count_with_params - 1) / limit).to_i
  end

  def current_page
    (offset / limit).to_i
  end

  # for override
  def extra_paging_path_args
    {}
  end

  private

  def contextual_param param
    env_search_param(param) || voo_search_param(param)
  end

  def env_search_param param
    val = Env.params[param]
    val = val.to_i if focal? && val.present?
    enforce_legal_limit! val
    val
  end

  def enforce_legal_limit! val
    return if Card::Auth.signed_in? || !val || val <= MAX_ANONYMOUS_SEARCH_PARAM

    raise Card::Error::PermissionDenied,
          "limit parameter exceeds maximum for anonymous users " \
          "(#{MAX_ANONYMOUS_SEARCH_PARAM})"
  end

  def voo_search_param param
    voo&.cql&.dig(param)&.to_i
  end
end
