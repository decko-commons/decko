include_set Abstract::ModAssets

def subpath
  "script"
end

def update_asset_output
  item_cards.map do |icard|
    icard.update_asset_output
  end
end

def local_folder_group_type_id
  ::Card::LocalScriptFolderGroupID
end

def local_manifest_group_type_id
  ::Card::LocalScriptManifestGroupID
end

format :html do
  view :javascript_include_tag do
    card.item_cards.map do |icard|
      nest icard, view: :javascript_include_tag
    end.join("\n")
  end
end
