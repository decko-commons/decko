# TODO: We can't detect file removal for folder group

include_set List

def modname
  codename.to_s.gsub(/^mod_/, "")
end

def ensure_mod_script_card
  ensure_mod_asset_card :script
end

def ensure_mod_style_card
  ensure_mod_asset_card :style
end

private

def ensure_mod_asset_card asset_type
  asset_card = fetch_mod_assets_card asset_type
  return if asset_card.no_action?
  asset_card.save! if asset_card.new? || asset_card.codename.blank?

  if asset_card.content?
    add_mod_asset_card asset_type
    asset_card.refresh_asset
  else
    puts "Drop: #{asset_card.name}"
    drop_mod_asset_card asset_type, asset_card
  end
end

def add_mod_asset_card asset_type
  target = asset_type == :style ? Card[:style_mods] : all_rule(asset_type)
  target.add_item! codename_for(asset_type)
end

def drop_mod_asset_card asset_type, asset_card
  asset_card.update codename: nil
  asset_card.delete
  all_rule(asset_type).drop_item! asset_card
end

def codename_for asset_type
  [codename, asset_type]
end

def all_rule asset_type
  Card[:all, asset_type]
end

def fetch_mod_assets_card asset_type
  codename = codename_for asset_type
  if Card::Codename.exists? codename
    Card[codename.to_sym]
  else
    card = Card.fetch [name, asset_type], new: {
      type_id: Card::ListID, codename: codename
    }
    card.codename = codename
    card.type_id = Card::ListID
    card
  end
end
