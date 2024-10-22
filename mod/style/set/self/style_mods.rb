include_set Abstract::AssetInputter, input_format: :scss

# find all theme cards that appear in style rules
def dependent_asset_inputters
  Card::Assets.active_theme_cards
end

format :html do
  view :remote_style_tags, cache: :deep, perms: :none do
    card.item_cards.map do |mod_style_card|
      nest mod_style_card, view: :remote_include_tags
    end.select(&:present?)
  end
end
