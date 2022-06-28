include_set Abstract::SkinField

event :validate_item_type, :validate, on: :save, before: :validate_asset_inputs, changed: :content do
  item_cards.each do |item|
    next if %i[css scss].include? item.type_code
    errors.add :content,
               t(:bootstrap_invalid_item_type, item: item.name, type: item.type)
  end
end
