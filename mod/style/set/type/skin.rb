include_set Abstract::AssetInputter, input_format: :css, input_view: :concat
include_set Abstract::SkinBox
include_set List

format :css do
  view :concat do
    card.item_cards.map do |item|
      item.respond_to?(:asset_input) ? item.asset_input : nest(item, view: :core)
    end.join("\n")
  end
end

event :no_deletion_if_used, :validate, on: :delete do
  if Card[:all, :style].item_keys.contains key
    errors.add :delete, t(:style_delete_error_skin_used)
  end
end
