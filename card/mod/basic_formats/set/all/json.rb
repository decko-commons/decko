format :json do
  # because card.item_cards returns "[[#{self}]]"
  def item_cards
    uniq_nested_cards
  end

  def default_nest_view
    :atom
  end

  def default_item_view
    params[:item] || :name
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

  view :status, unknown: true, perms: :none do
    status = card.state
    hash = { key: card.key,
             url_key: card.name.url_key,
             status: status }
    hash[:id] = card.id if status == :real
    hash
  end

  # NOCACHE because of timestamp
  view :page, cache: :never do
    { url: request_url,
      timestamp: Time.now.to_s,
      card: _render_atom }
  end

  def request_url
    req = controller.request
    req ? req.original_url : path
  end

  view :core do
    card.known? ? render_content : nil
  end

  view :content do
    card.content
  end

  view :nucleus do
    nucleus
  end

  # TODO: add simple values for fields
  view :atom, unknown: true do
    atom
  end

  view :molecule do
    atom.merge items: _render_items,
               links: _render_links,
               ancestors: _render_ancestors,
               html_url: path,
               type: nest(card.type_card, view: :nucleus)

  end

  # NOCACHE because sometimes item_cards is dynamic.
  # could be safely cached for non-dynamic lists
  view :items, cache: :never do
    listing item_cards, view: :atom
  end

  view :links do
    card.link_chunks.map do |chunk|
      if chunk.referee_name
        path mark: chunk.referee_name, format: :json
      else
        link_to_resource chunk.link_target
      end
    end
  end

  view :ancestors do
    card.name.ancestors.map do |name|
      nest name, view: :nucleus
    end
  end

  # minimum needed to re-fetch card
  view :cast do
    card.cast
  end

  ## DEPRECATED
  view :marks do
    {
      id: card.id,
      name: card.name,
      key: card.key,
      url: path
    }
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

  # NOTE: moving these to methods prevents potential caching problems, because other
  # views manipulate their hashes.
  #
  def nucleus
    h = { id: card.id,
          name: card.name,
          type: card.type_name,
          url: path(format: :json) }
    h[:codename] = card.codename if card.codename
    h
  end

  def atom
    h = nucleus
    h[:content] = render_content if card.known? && !card.structure
    h
  end
end

# TODO: perhaps this should be in a general "data" module.
def cast
  real? ? { id: id } : { name: name, type_id: type_id, content: db_content }
end
