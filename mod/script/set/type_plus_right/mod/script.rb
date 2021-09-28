include_set Abstract::ModAssets

def subpath
  "script"
end

def update_asset_output
  outputter_cards.map do |icard|
    icard.update_asset_output
  end
end

def local_folder_group_type_id
  ::Card::LocalScriptFolderGroupID
end

def local_manifest_group_type_id
  ::Card::LocalScriptManifestGroupID
end

def outputter_cards
  item_cards.select do |item|
    item.is_a? Abstract::AssetOutputter
  end
end
