include_set Abstract::AssetInputter, input_format: :scss

# find all theme cards that appear in style rules
def dependent_asset_inputters
  Card::Assets.active_theme_cards
end
