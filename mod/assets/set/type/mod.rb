def ensure_mod_asset_card asset_type, codename, type_id
  asset_card = find_or_create_mod_assets_card asset_type, codename, type_id

  asset_card.update_items
  if asset_card.item_cards.present?
    Card[:all, asset_type].add_item! codename.to_sym
  else
    asset_card.update codename: nil
    asset_card.delete update_referers: true
    Card[:all, asset_type].drop_item! asset_card
  end
end

def ensure_mod_script_card
  ensure_mod_asset_card :script, script_codename, Card::ModScriptAssetsID
end

def ensure_mod_style_card
  ensure_mod_asset_card :style, style_codename, Card::ModStyleAssetsID
end

def find_or_create_mod_assets_card field_name, codename, type_id
  if Card::Codename.exists? codename
    Card.fetch codename.to_sym
  else
    Card.create name: [name, field_name],
                type_id: type_id,
                codename: codename
  end
end

def script_codename
  "#{codename}_script"
end

def style_codename
  "#{codename}_style"
end
