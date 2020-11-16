include_set Abstract::Pointer

abstract_basket :item_codenames

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

def subpath
  "assets/javascript/libraries"
end

def asset_file_cards
  Card::Mod.dirs.map_paths(subpath) do |mod, path|
    manifest_path = File.join(path, "manifest.yml")
    if File.exists? manifest_path
      asset_file_cards_from_manifest mod, manifest_path
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

def asset_file_cards_from_manifest mod, manifest_path
  yaml = YAML.load_file manifest_path
  return unless yaml["include"].present?

  asset_file_cards_from_paths mod, File.dirname(manifest_path), yaml["include"]
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
