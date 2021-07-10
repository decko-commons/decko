def ensure_mod_style_card
  ensure_mod_asset_card :style, style_codename, Card::ModStyleAssetsID
  Card[:all, :style].add_item! "yeti skin"
end
