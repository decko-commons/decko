include_set List

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

  # TODO: optimize!
  # this needs to be smarter so that it doesn't do a lot of "re" installing
  # when things are already set up.
  asset_card.update_items
  if asset_card.item_cards.present?
    add_asset asset_type
  else
    puts "Drop: #{asset_card.name}"
    drop_asset asset_type, asset_card
  end
end

def add_asset asset_type
  target = asset_type == :style ? Card[:style_mods] : all_rule(asset_type)
  target.add_item! codename_for(asset_type).to_sym
end

def drop_asset asset_type, asset_card
  asset_card.update codename: nil
  asset_card.delete
  all_rule(asset_type).drop_item! asset_card
end

def codename_for asset_type
  "#{codename}_#{asset_type}"
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
