event :validate_item_type, :validate, on: :save do
  item_cards.each do |item|
    next if allowed_types.include? item.type_code

    errors.add :content, t(:list_invalid_item_type, item: item.name,
                           type: item.type,
                           allowed_types: allowed_types.map { |type_code| Card::Name[type_code]}.to_sentence)
  end
end