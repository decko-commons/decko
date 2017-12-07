format do
  def limit_param
    @limit ||= contextual_param(:limit) || default_limit
  end

  def offset_param
    @offset ||= contextual_param(:offset) || 0
  end

  def contextual_param param, int=true
    env_search_param(param) || voo_search_param(param)
  end

  def env_search_param param, int=true
    return unless focal?
    val = Env.params[param]
    return unless val.present?
    int ? val.to_i : val
  end

  def voo_search_param param
    return unless voo.query
    voo.query[param]
  end
end
