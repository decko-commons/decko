include_set Abstract::ReadOnly
include_set Abstract::Sources
include_set Abstract::Items

def update_if_source_file_changed
  return unless !output_updated_at || source_changed?(since: output_updated_at)

  update_items!
end

event :update_asset_list, :prepare_to_store, on: :save do
  self.db_content = relative_paths.join("\n")
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
  asset_card
end

def source_paths
  paths
end

def self_machine_input?
  true
end

def local
  @local = true
end

def minimize?
  @minimize = true
end

def source_changed? since:
  difference = (relative_paths + item_names) - (relative_paths & item_names)
  difference.present? ||
    existing_source_paths.any? { |path| ::File.mtime(path) > since }
end
