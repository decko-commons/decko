# include_set Abstract::AssetOutputter, output_format: :js

def input_item_cards
  item_cards.reject do |item_card|
    item_card.is_a? Abstract::ModAssets
  end
end

event :validate_script_item_type, :validate, on: :save, changed: :content do
  item_cards.each do |item|
    errors.add :content, t(:script_invalid_item_type, item: item.name, type: item.type) unless %i[java_script coffee_script].include? item.type_code
  end
end

