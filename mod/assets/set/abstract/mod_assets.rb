include_set Abstract::Pointer
include_set Abstract::ReadOnly

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

def expected_item_keys
  return [] unless assets_dir_exists?

  if manifest_exists?
    manifest.keys.map { |group_key| "#{name}+#{group_key}".to_name.key }
  else
    ["#{name}+#{local_group_name}".to_name.key]
  end
end

def local_group_name
  "local"
end

def update_items
  # return unless groups_changed?

  delete_unused_items do
    self.content = ""
    return unless assets_dir_exists?

    ensure_update_items
    save!
  end
end

def ensure_update_items
  if manifest_exists?
    ensure_manifest_groups_cards
  else
    ensure_assets_group_card local_group_name, local_folder_group_type_id
  end
end

def delete_unused_items
  @old_items = ::Set.new item_keys
  yield
  remove_deprecated_items @old_items
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

def ensure_manifest_groups_cards
  with_manifest_groups { |group_name, config| new_manifest_group group_name, config }
end

def new_manifest_group group_name, config
  type_id =
    config["remote"] ? ::Card::RemoteManifestGroupID : local_manifest_group_type_id
  ensure_assets_group_card group_name, type_id
end

def ensure_assets_group_card field, type_id
  item_name = "#{name}+#{field}"
  ensure_group_card_is_added item_name

  card = Card[item_name]
  args = ensure_item_args field, type_id, item_name
  return if item_already_coded? card, args

  ensure_item_save card, args
  # card.try :update_asset_output
end

def item_already_coded? card, args
  card&.type_id == args[:type_id] && card.codename == args[:codename]
end

def ensure_group_card_is_added item_name
  @old_items.delete item_name.to_name.key
  add_item item_name
end

def ensure_item_save card, args
  if card
    card.update args
  else
    Card.create! args
  end
end

def ensure_item_args field, type_id, name
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

def remove_deprecated_items items
  items.each do |deprecated_item|
    next unless (item_card = Card.fetch(deprecated_item))
    item_card.update codename: nil
    item_card.delete
  end
end
