include_set Abstract::AssetInputter, input_format: :scss

# find all theme cards that appear in style rules
def dependent_asset_inputters
  style_rule = { left: { type_id: Card::SetID }, right_id: StyleID }
  Card.search(referred_to_by: style_rule).select do |theme|
    theme.respond_to? :theme_name
  end
end

