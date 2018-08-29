format :json do
  # because card.item_cards returns "[[#{self}]]"
  def item_cards
    uniq_nested_cards
  end

  def default_nest_view
    :atom
  end

  def default_item_view
    params[:item] || :atom
  end

  def max_depth
    params[:max_depth].present? ? params[:max_depth].to_i : 1
  end

  # TODO: support layouts in json
  # eg layout=stamp gives you the metadata currently in "page" view
  # and layout=none gives you ONLY the requested view (default atom)
  def show view, args
    view ||= :molecule
    raw = render! view, args
    return raw if raw.is_a? String
    method = params[:compress] ? :generate : :pretty_generate
    JSON.send method, raw
  end

  view :status, tags: :unknown_ok, perms: :none, cache: :never do
    status = card.state
    hash = { key: card.key,
             url_key: card.name.url_key,
             status: status }
    hash[:id] = card.id if status == :real
    hash
  end

  view :page, cache: :never do
    { url: request_url,
      timestamp: Time.now.to_s,
      card: _render_atom }
  end

  view :content do
    render_page
  end

  view :core do
    { card.name => card.content }
  end

  view :nucleus, cache: :never do
    {
      id: card.id,
      name: card.name,
      url: path(format: :json),
      html_url: path
    }
  end

  view :atom, cache: :never do
    h = _render_nucleus
    h[:type] = card.type_name
    h[:type_url] = path mark: card.type_name, format: :json
    h[:atom_url] = path format: :json, view: :atom
    h[:nucleus_url] = path format: :json, view: :nucleus
    h[:content] = card.db_content unless card.structure
    h[:codename] = card.codename if card.codename
    h
  end

  view :items, cache: :never do
    listing item_cards
  end

  view :links, cache: :never do
    card.link_chunks.map do |chunk|
      if chunk.referee_name
        path mark: chunk.referee_name, format: :json
      else
        link_to_resource chunk.link_target
      end
    end
  end

  view :ancestors, cache: :never do
    card.name.ancestors.map do |name|
      nest name
    end
  end

  view :molecule, cache: :never do
    _render_atom.merge items: _render_items,
                       links: _render_links,
                       ancestors: _render_ancestors

  end

  # minimum needed to re-fetch card
  view :cast, cache: :never do
    card.cast
  end

  view :marks do
    {
      id: card.id,
      name: card.name,
      key: card.key,
      url: path
    }
  end

  view :export_item do
    item = { name: card.name, type: card.type_name, content: card.content }
    item[:codename] = card.codename if card.codename
    item
  end

  view :essentials do
    if voo.show? :marks
      render_marks.merge(essentials)
    else
      essentials
    end
  end

  def essentials
    return {} if card.structure
    { content: card.db_content }
  end

  def request_url
    req = controller.request
    req ? req.original_url : path
  end
end

# TODO: perhaps this should be in a general "data" module.
def cast
  real? ? { id: id } : { name: name, type_id: type_id, content: db_content }
end
