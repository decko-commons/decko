# include_set Abstract::AssetOutputter, output_format: :js
include_set Abstract::AssetInputter, input_format: :js
include_set Abstract::ModAssets

def subpath
  "script"
end

def folder_group_type_id
  ::Card::LocalScriptFolderGroupID
end

def local_manifest_group_type_id
  ::Card::LocalScriptManifestGroupID
end

format :html do
  view :remote_script_tags, cache: :never do
    remote_include_tags.compact.join "\n"
  end

  def remote_include_tags
    map_remote_items do |tag_args|
      javascript_include_tag tag_args.delete("src"), tag_args
    end
  end
end
