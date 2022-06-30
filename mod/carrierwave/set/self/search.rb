format :json do
  view :image_complete, cache: :never do
    complete_or_match_search(start_only: match_start_only?,
                             additional_cql: { type: :image }).map do |name|
      goto_item_text name
    end
  end
end
