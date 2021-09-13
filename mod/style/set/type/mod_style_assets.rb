include_set Abstract::AssetInputter, input_format: :css
include_set Abstract::ModAssets

def subpath
  "style"
end

def local_folder_group_type_id
  ::Card::LocalStyleFolderGroupID
end

def local_manifest_group_type_id
  ::Card::LocalStyleManifestGroupID
end

format :html do
  view :stylesheet_include_tag do
    card.item_cards.map do |icard|
      nest icard, view: :stylesheet_include_tag
    end.join("\n")
  end
end
