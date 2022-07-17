format :json do
  # because card.item_cards returns "[[#{self}]]"
  def item_cards
    nested_cards
  end

  def default_nest_view
    :atom
  end

  def default_item_view
    :name
  end

  def max_depth
    params[:max_depth].present? ? params[:max_depth].to_i : 1
  end

  # TODO: support layouts in json
  # eg layout=stamp gives you the metadata currently in "page" view
  # and layout=none gives you ONLY the requested view (default atom)
  def show view, args
    view ||= :molecule
    string_with_page_details do
      render! view, args
    end
  end

  view :status, unknown: true, perms: :none do
    { key: card.key,
      url_key: card.name.url_key,
      status: card.state }.tap do |h|
      h[:id] = card.id if h[:status] == :real
    end
  end

  view :page, cache: :never do
    page_details card: render_atom
  end

  private

  def string_with_page_details
    raw = yield
    return raw if raw.is_a? String

    stringify page_details(raw)
  end

  def page_details obj
    return obj unless obj.is_a? Hash

    obj.merge url: request_url, requested_at: Time.now.to_s
  end

  def stringify raw
    method = params[:compress] ? :generate : :pretty_generate
    JSON.send method, raw
  end
end
