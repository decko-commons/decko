# include_set Abstract::AssetOutputter, output_format: :js

def input_item_cards
  item_cards.reject do |item_card|
    item_card.is_a? Abstract::ModAssets
  end
end
