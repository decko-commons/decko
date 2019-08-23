format :html do
  view :core do
    # Rule cards that are searches are usual right structures and refer to the left
    # in the search query. In that case the search doesn't work
    # properly in the context of the rule card itself.  Hence we show the query syntax
    # and not the search result.
    if card.type_id == Card::SearchTypeID
      render_raw
    else
      super()
    end
  end
end