include_set Abstract::List
include_set Abstract::ReadOnly

card_accessor :group_remote

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
  card.assets_path = assets_path
  card
end

def local_manifest_group_cards
  manifest.map do |group_name, _config|
    next if remote_group? group_name

    new_local_manifest_group_card group_name
  end.compact
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

def remote_group? name
  name == "remote"
end

def manifest_group_items group_name
  manifest&.dig(group_name, "items") || []
end

def manifest_group_minimize? group_name
  manifest.dig group_name, "minimize"
end

def manifest
  # FIXME: sometimes this needs to get cleared!
  @manifest ||= load_manifest
end

def load_manifest
  return unless manifest_exists?

  manifest = YAML.load_file manifest_path
  return {} unless manifest # blank manifest

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

  source_updates.present? && (source_updates.max > since)
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
  Card.new group_card_args(group_name, type_id, item_name)
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
  def map_remote_items &block
    card.group_remote_card.map_items(&block)
  end

  view :core do
    groups = []
    urls = card.group_remote_card.urls
    groups << ["group: remote", urls] if urls.present?

    card.item_cards.map do |item|
      groups << [item.cardname.tag, item.input_item_cards.map(&:name)]
    end

    haml :group_list, groups: groups
  end
end
