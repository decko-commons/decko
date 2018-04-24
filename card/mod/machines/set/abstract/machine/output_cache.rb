def fetch_cache_card input_card, new=nil
  new &&= { type_id: PlainTextID }
  Card.fetch input_card.name, name, :machine_cache, new: new
end

def cache_output_part input_card, output
  Auth.as_bot do
    # save virtual cards first
    # otherwise the cache card will save it to get the left_id
    # and trigger the cache update again
    input_card.save! if input_card.new_card?

    cache_card = fetch_cache_card(input_card, true)
    cache_card.update_attributes! content: output
  end
end
