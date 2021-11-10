def cast
  real? ? { id: id } : { name: name, type_id: type_id, content: db_content }
end

def export_hash field_tags: []
  { name: export_name, type: type_name.codename_or_string }.tap do |h|
    h[:codename] = codename if codename.present?
    h[:content] = export_content if export_content.present?
    export_subfields h, field_tags if field_tags.present?
  end
end

def export_subfields export_hash, marks
  marks.each do |mark|
    next unless (subcontent = [name, mark].card&.export_content)
    export_hash[:subfields] ||= {}
    export_hash[:subfields][mark] = subcontent
  end
end

def export_name
  simple? ? name.s : name.part_names.map(&:codename_or_string)
end

def export_content
  structure ? nil : db_content
end

format :data do
  view :export do
    card.export_hash
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
end
