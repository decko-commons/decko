def ensure_mod_script_card
  ensure_mod_asset_card :script, Card::ModScriptAssetsID
end

def ensure_mod_style_card
  ensure_mod_asset_card :style, Card::ModStyleAssetsID
end

private

def ensure_mod_asset_card asset_type, type_id
  asset_card = fetch_mod_assets_card asset_type, type_id
  return if asset_card.no_action?
  asset_card.save! if asset_card.new?

  asset_card.update_items
  if asset_card.item_cards.present?
    add_asset asset_type
  else
    drop_asset asset_type, asset_card
  end
end

def add_asset asset_type
  all_rule(asset_type).add_item! codename_for(asset_type).to_sym
end

def drop_asset asset_type, asset_card
  asset_card.update codename: nil
  asset_card.delete update_referers: true
  all_rule(asset_type).drop_item! asset_card
end

def codename_for asset_type
  "#{codename}_#{asset_type}"
end

def all_rule asset_type
  Card[:all, asset_type]
end

def fetch_mod_assets_card asset_type, type_id
  codename = codename_for asset_type
  if Card::Codename.exists? codename
    Card[codename.to_sym]
  else
    Card.fetch [name, asset_type], new: {
      type_id: type_id,
      codename: codename
    }
  end
end
