include_set Abstract::ModAssets
include_set Abstract::AssetOutputter, output_format: :js

def subpath
  "script"
end

def local_folder_group_type_id
  ::Card::LocalScriptFolderGroupID
end

def local_manifest_group_type_id
  ::Card::LocalScriptManifestGroupID
end
