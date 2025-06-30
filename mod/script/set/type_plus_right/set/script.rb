include_set Abstract::AssetOutputter, output_format: :js

def ok_item_types
  %i[java_script coffee_script list]
end

def input_item_cards
  item_cards.reject do |item_card|
    item_card.is_a? Abstract::ModAssets
  end
end
