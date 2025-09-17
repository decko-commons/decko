format :jsonld do
  # Default: JSON-LD not supported (can be overridden by any set)
  def jsonld_supported? = false

  view :items, cache: :never do
    listing_list item_cards, view: voo_items_view || :molecule
  end

  def show view, args
    jsonld_supported? ? super : render_format_unsupported
  end

  def molecule
    {
      "@id": path,
      "@context": "https://www.w3.org/ns/hydra/core#",
      "@type": "hydra:Collection",
      "hydra:member": _render_items
    }.compact
  end
end
