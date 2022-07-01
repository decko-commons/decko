format :json do
  view :image_complete, cache: :never do
    complete_or_match_search(start_only: false,
                             additional_cql: { type: :image }).map do |item|
      { id: item, href: item.url_key, text: goto_item_text(item) }
    end
  end
end
