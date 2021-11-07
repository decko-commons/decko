def cast
  real? ? { id: id } : { name: name, type_id: type_id, content: db_content }
end

format :data do
  view :export do
    {
      name: card.name.to_s,
      type: export_type,
      codename: card.codename,
      content: card.db_content
    }
  end

  view :core, unknown: true do
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
    molecule
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

  # NOCACHE because sometimes item_cards is dynamic.
  # could be safely cached for non-dynamic lists
  view :items, cache: :never do
    listing item_cards, view: (voo_items_view || :atom)
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

  # NOTE: moving these to methods prevents potential caching problems, because other
  # views manipulate their hashes.
  def nucleus
    { id: card.id,
      name: card.name,
      type: card.type_name,
      url: path(format: :json) }.tap do |h|
      h[:codename] = card.codename if card.codename
    end
  end

  def atom
    nucleus.tap do |h|
      h[:content] = render_content if card.known? && !card.structure
    end
  end

  def molecule
    atom.merge items: _render_items,
               links: _render_links,
               ancestors: _render_ancestors,
               html_url: path,
               type: nest(card.type_card, view: :nucleus),
               created_at: card.created_at,
               updated_at: card.updated_at
  end

  private

  def export_type
    tc = card.type_card
    tc.codename || tc.name
  end
end
