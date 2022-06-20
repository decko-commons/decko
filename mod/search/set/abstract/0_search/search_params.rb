format do
  def search_params
    @search_params ||= default_search_params
  end

  # used for override
  def default_search_params
    if (qparams = query_params)&.present?
      paging_params.merge vars: qparams
    else
      paging_params
    end
  end

  def paging_params
    { limit: limit, offset: offset }
  end

  def query_params
    (vars = params[:query]) ? Env.hash(vars) : {}
  end

  def default_limit
    100
  end

  def extra_paging_path_args
    (vars = query_params) ? { query: vars } : {}
  end
end

format :html do
  def default_limit
    Cardio.config.paging_limit || 20
  end
end

format :json do
  def default_limit
    20
  end
end

format :rss do
  def default_limit
    25
  end
end
