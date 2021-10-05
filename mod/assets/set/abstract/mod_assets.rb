include_set Abstract::Pointer
include_set Abstract::ReadOnly

def input_item_cards
  local_group_cards
end

# group cards that don't refer to remote sources
def local_group_cards
  if manifest_exists?
    local_manifest_group_cards
  else
    local_folder_group_card
  end
end

def remote_group_urls
  return unless manifest_exists?
  manifest_group_items "remote"
end

def local_folder_group_card
  return unless assets_path
  card = new_assets_group_card local_group_name,
                               local_folder_group_type_id
  card.assets_path = assets_path
  card
end

def local_manifest_group_cards
  with_manifest_groups do |group_name, config|
    next if remote_group?(name, config)
    new_local_manifest_group_card group_name, config
  end
end

def has_content?
  assets_path
end

def mod_name
  left&.codename.to_s.sub(/^mod_/, "")
end

def mod
  @mod ||= Cardio::Mod.dirs.fetch_mod(mod_name)
end

def assets_path
  return unless mod&.assets_path.present?

  File.join mod&.assets_path, subpath
end

def manifest_path
  return unless assets_path

  File.join(assets_path, "manifest.yml")
end

def local_group_name
  "local"
end

def remote_group? name, config
  name == "remote" || config["remote"]
end

def assets_dir_exists?
  path = assets_path
  path && Dir.exist?(path)
end

def manifest_exists?
  manifest_path && File.exist?(manifest_path)
end

def manifest_group_items group_name
  manifest.dig(group_name, "items") || []
end

def manifest_group_minimize? group_name
  manifest.dig group_name, "minimize"
end

def manifest
  @manifest ||= YAML.load_file manifest_path
end

def with_manifest_groups
  manifest.each_pair do |key, config|
    yield key, config
  end
end

def new_local_manifest_group group_name
  card = new_assets_group_card group_name, local_manifest_group_type_id
  card.relative_paths = manifest_group_items(group_name)
  card
end

def new_assets_group_card group_name, type_id
  item_name = "#{name}+group: #{group_name}"
  card = Card.new group_card_args(group_name, type_id, item_name)
  card
end

def group_card_args field, type_id, name
  {
    type_id: type_id,
    codename: "#{mod_name}_group__#{field}",
    name: name
  }
end

def refresh_output force: false
  update_items
  item_cards.each do |item_card|
    item_card.try :refresh_output, force: force
  end
end

def make_asset_output_coded verbose=false
  item_cards.each do |item_card|
    puts "coding asset output for #{item_card.name}" if verbose
    item_card.try(:make_asset_output_coded, mod_name)
  end
end

def source_changed?
  last_source_update =
    [manifest_updated_at, local_manifest_group_cards.map(&:last_file_change)].flatten.max
  last_source_update > updated_at
end

def manifest_updated_at
  return unless manifest_exists?
  File.mtime(manifest_path)
end

def no_action?
  new? && !assets_dir_exists?
end

private

# def groups_changed?
#   expected_items = expected_item_keys
#   actual_items = item_keys
#   difference = (expected_items + actual_items) - (expected_items & actual_items)
#   difference.present?
# end
