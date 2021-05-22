include_set Abstract::Machine
include_set Abstract::MachineInput
include_set Abstract::ReadOnly
include_set Abstract::Sources
include_set Abstract::Items

machine_input { standard_machine_input }
store_machine_output filetype: "js"

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

def fetch_item_card name, args={}
  new_asset_file_card item_name_to_path(name)
end

def new_asset_file_card path, name = ::File.basename(path)
  type_id =
    if path.ends_with? ".js.coffee"
      Card::CoffeeScriptID
    elsif path.ends_with? ".js"
      Card::JavaScriptID
    else
      return
    end
  asset_card = Card.new name: name,
                        type_id: type_id,
                        content: path

  if path.ends_with? ".js.coffee"
    asset_card.include_set_module ::Card::Set::Abstract::AssetCoffeeScript
  elsif path.ends_with? ".js"
    asset_card.include_set_module ::Card::Set::Abstract::AssetJavaScript
  end
  asset_card.minimize if @minimize
  asset_card.local if @local
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

=begin
def item_names
  item_cards.map { |c| c.name }
end
=end

=begin
def content
  item_names.to_pointer_content
end
=end

def standard_machine_input
  item_cards.map do |mcard|
    js = mcard.format(:js)._render_core
    js = mcard.compress_js js if minimize?
    "// #{mcard.name}\n#{js}"
  end.join "\n"
end

format :html do
  view :javascript_include_tag do
    javascript_include_tag card.machine_output_url
  end
end

def source_changed? since:
  difference = (relative_paths + item_names) - (relative_paths & item_names)
  difference.present? ||
    existing_source_paths.any? { |path| ::File.mtime(path) > since }
end