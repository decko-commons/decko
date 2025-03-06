include_set Abstract::ReadOnly
include_set Abstract::Sources
include_set Abstract::Items

def virtual?
  new?
end

def render_items_and_compress format
  item_cards.compact.map do |mcard|
    mcard.format(format)._render_compressed
  end.join "\n"
end

def item_cards _args={}
  relative_paths.map do |path|
    new_asset_file_card path
  end.compact
end

def new_asset_file_card path, name=::File.basename(path)
  return unless (constants = new_asset_constants path)

  asset_card = Card.new(name: name, type_id: constants[:type_id], content: path)
  asset_card.include_set_module constants[:set_module]
  asset_card.minimize if @minimize
  asset_card.local if @local
  asset_card.base_path = base_path
  asset_card.files_must_exist!
  asset_card
end

def source_paths
  paths
end

def local
  @local = true
end

def source_changed? since:
  existing_source_paths.any? { |path| ::File.mtime(path) > since }
end

def input_item_cards
  item_cards # we create virtual cards for manifest groups, hence we have
  # to override the default which rejects virtual cards.
end

def asset_input_needs_refresh?
  !asset_input_updated_at || source_changed?(since: asset_input_updated_at)
end

def last_file_change
  paths.map { |path| ::File.mtime(path) }.max
end
