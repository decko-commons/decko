include_set Abstract::PagingParams

format do
  def offset
    search_params[:offset] || 0
  end

  def search_params
    @search_params ||= default_search_params
  end

  # used for override
  def default_search_params
    if (qparams = query_params)
      paging_params.merge vars: qparams
    else
      paging_params
    end
  end

  def paging_params
    { limit: limit_param, offset: offset_param }
  end

  def query_params
    return nil unless (query_param = params[:query])
    Card.safe_param query_param
  end

  def default_limit
    100
  end
end

format :html do
  def default_limit
    Cardio.config.paging_limit || 20
  end
end

format :json do
  def default_limit
    0
  end
end

format :rss do
  def default_limit
    25
  end
end
