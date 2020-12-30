include_set Abstract::Pointer

abstract_basket :item_codenames

def self.included host_class
  host_class.include_set Abstract::Machine
  host_class.include_set Abstract::MachineInput

  host_class.machine_input { standard_machine_input }
  host_class.store_machine_output filetype: "js"
end

def standard_machine_input
  manifest_groups_cards.reject { |mcard| !mcard.local }.map do |mcard|
    js = mcard.format(:js)._render_core
    js = compress_js js if mcard.minimize
    js
  end.join "\n"
end

# simplify api
# Self::MyCodePointerSet.add_item :my_item_codename
# instead of
# Self::MyCodePointerSet.add_to_basket :item_codenames, :my_item_codename
module ClassMethods
  def add_item codename
    valid_codename codename do
      add_to_basket :item_codenames, codename
    end
  end

  def unshift_item codename
    valid_codename codename do
      unshift_basket :item_codenames, codename
    end
  end

  def valid_codename codename
    if Card::Codename.exist? codename
      yield
    else
      Rails.logger.info "unknown codename '#{codename}' added to code pointer"
    end
  end
end

def asset_file_cards
  Card::Mod.dirs.map_paths(subpath) do |mod, path|
    manifest_path = File.join(path, "manifest.yml")
    if File.exists? manifest_path
      manifest_groups_cards mod, manifest_path
    else
      asset_file_cards_from_paths mod, path, Dir::children(path)
    end
  end.flatten.compact
end

def asset_file_cards_from_paths mod, basepath, filenames
  filenames.map do |filename|
    Card.fetch "#{mod}: #{filename}",
               local_only: true,
               new: { content: File.join(basepath, filename),
                      type_id: Card::AssetFileID }
    end
end

def manifest_groups_cards mod, manifest_path
  yaml = YAML.load_file manifest_path
  yaml.keys.map do |key|
    new_manifest_group key, yaml[key]
  end
end

def new_manifest_group key, config
  group = Card.new name: key, type_id: Card::ManifestGroupID
  group.minimize if config["minimize"]
  group.local if config["local"]
  group.add_items config["items"]
  group
end

format :html do
  view :include_tag do
    card.item_cards.map do |icard|
      nest icard, view: :include_tag
    end.join("\n")
  end
end

def basket_cards
  item_codenames.map do |codename|
      Card.fetch codename
  end.compact
end

def basket_card_names
  item_codenames.map do |codename|
      Card.fetch_name codename
  end.compact
end

def item_cards content=nil
  asset_file_cards + basket_cards
end

def content
  (asset_file_cards.map { |c| c.name } + basket_card_names).to_pointer_content
end
