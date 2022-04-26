include_set Abstract::Pointer
include_set Abstract::ReadOnly

def item_cards _args={}
  local_group_cards
end

def item_names _args={}
  local_group_cards.map(&:name)
end

# group cards that don't refer to remote sources
def local_group_cards
  @local_group_cards ||=
    if manifest_exists?
      local_manifest_group_cards
    else
      [folder_group_card].compact
    end
end

def folder_group_card
  return unless assets_path
  card = new_assets_group_card local_group_name, folder_group_type_id
  binding.pry unless card.respond_to? "assets_path="
  card.assets_path = assets_path
  card
end

def local_manifest_group_cards
  manifest.map do |group_name, config|
    next if remote_group?(group_name, config)
    new_local_manifest_group_card group_name
  end.compact
end

def remote_group_urls
  return unless manifest_exists?
  manifest_group_items "remote"
end

def content?
  assets_path
end

def mod_name
  left&.codename.to_s.sub(/^mod_/, "")
end

def mod
  @mod ||= Cardio::Mod.fetch mod_name
end

def manifest_exists?
  @manifest_exists = !manifest_path.nil? if @manifest_exists.nil?
  @manifest_exists
end

def assets_path
  @assets_path ||= mod&.subpath "assets", subpath
end

def manifest_path
  @manifest_path ||= mod&.subpath "assets", subpath, "manifest.yml"
end

def local_group_name
  "local"
end

def remote_group? name, _config
  name == "remote" # || config["remote"]
end

def manifest_group_items group_name
  manifest&.dig(group_name, "items") || []
end

def manifest_group_minimize? group_name
  manifest.dig group_name, "minimize"
end

def manifest
  @manifest ||= load_manifest
end

def load_manifest
  return unless manifest_exists?
  manifest = YAML.load_file manifest_path
  validate_manifest manifest
  manifest
end

def validate_manifest manifest
  if (remote_index = manifest.keys.find_index("remote")) && remote_index.positive?
    raise_manifest_error "only the first group can be a remote group"
  end
  manifest.each do |name, config|
    validate_manifest_item name, config
  end
end

def group_card_args field, type_id, name
  {
    type_id: type_id,
    codename: "#{mod_name}_group__#{field}",
    name: name
  }
end

def source_changed? since:
  source_updates =
    if manifest_exists?
      [manifest_updated_at, local_manifest_group_cards.map(&:last_file_change)].flatten
    else
      folder_group_card&.paths&.map { |path| File.mtime(path) }
    end

  return unless source_updates.present?

  source_updates.max > since
end

def manifest_updated_at
  return unless manifest_exists?
  File.mtime(manifest_path)
end

def no_action?
  new? && !assets_path
end

private

def new_local_manifest_group_card group_name
  card = new_assets_group_card group_name, local_manifest_group_type_id
  card.group_name = group_name
  card
end

def new_assets_group_card group_name, type_id
  item_name = "#{name}+group: #{group_name}"
  card = Card.new group_card_args(group_name, type_id, item_name)
  card
end

def validate_manifest_item name, config
  raise_manifest_error "no items section in group \"#{name}\"" unless config["items"]
  return if config["items"].is_a? Array

  raise_manifest_error "items section \"#{name}\" must contain a list"
end

def raise_manifest_error msg
  raise Card::Error, "invalid manifest format in #{manifest_path}: #{msg}"
end

format :html do
  def map_remote_items
    remote_items = card.manifest_group_items "remote"
    return unless remote_items

    remote_items.map { |args| yield args.clone }
  end
end
