event :validate_item_type, :validate, on: :save do
  item_cards.each do |item|
    next if %i[css scss].include? item.type_code

    errors.add :content, t(:style_invalid_item_type, item: item.name, type: item.type)
  end
end