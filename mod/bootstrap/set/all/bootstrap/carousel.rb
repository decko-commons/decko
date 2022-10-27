format :html do
  view :carousel do
    bs_carousel unique_id, 0 do
      nest_item_array.each do |rendered_item|
        item(rendered_item)
      end
    end
  end
end
