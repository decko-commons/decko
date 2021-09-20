include_set Abstract::ReadOnly
include_set Abstract::Sources
include_set Abstract::Items

def refresh_output force: false
  update_items! if refresh_output? || force
end

def refresh_output?
  !output_updated_at || source_changed?(since: output_updated_at)
end

event :update_asset_list, :prepare_to_store, on: :save do
  self.db_content = relative_paths.join("\n")
end

def render_items_and_compress format
  item_cards.compact.map do |mcard|
    js = mcard.format(format)._render_core
    # js = mcard.compress js if minimize?
    "// #{mcard.name}\n#{js}"
  end.join "\n"
end

def update_items!
  Card::Auth.as_bot do
    save!
  end
  regenerate_machine_output
end

def item_name_to_path name
  name
end

def fetch_item_card name, _args={}
  new_asset_file_card item_name_to_path(name)
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
  difference = (relative_paths + item_names) - (relative_paths & item_names)
  difference.present? ||
    existing_source_paths.any? { |path| ::File.mtime(path) > since }
end

def input_item_cards
  item_cards # we create virtual cards for manifest groups, hence we have
  # to override the default which rejects virtual cards.
end
