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

  def type_param
    type = query_params[:type]
    type.present? && type
  end

  def term_param
    params[:term]
  end

  def search_keyword
    @search_keyword ||= term_param || search_vars&.dig(:keyword)
  end

  def search_vars
    # root.respond_to?(:search_params) ? root.search_params[:vars] :
    search_params[:vars]
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
