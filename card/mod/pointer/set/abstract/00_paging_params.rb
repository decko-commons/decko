format do
  def limit_param
    @limit ||= contextual_param(:limit) || default_limit
  end

  def offset_param
    @offset ||= contextual_param(:offset) || 0
  end

  def contextual_param param
    env_search_param(param) || voo_search_param(param)
  end

  def env_search_param param
    return unless focal?
    val = Env.params[param]
    val.present? && val.to_i
  end

  def voo_search_param param
    return unless voo&.wql
    voo.wql[param]
  end
end
