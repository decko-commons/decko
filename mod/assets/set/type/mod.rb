# TODO: We can't detect file removal for folder group

include_set List

def modname
  codename.to_s.gsub(/^mod_/, "")
end

def ensure_mod_asset_card asset_type
  asset_card = fetch_mod_assets_card asset_type
  return unless asset_card.assets_path
  asset_card.save! if asset_card.new?
  asset_card.name
end

private

def fetch_mod_assets_card asset_type
  Card.fetch [name, asset_type], new: { type: :list }
end
