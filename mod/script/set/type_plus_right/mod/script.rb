include_set Abstract::AssetOutputter, output_format: :js
include_set Abstract::ModAssets

def make_asset_output_coded
  super(mod_name)
end

def subpath
  "script"
end

def folder_group_type_id
  Card::LocalScriptFolderGroupID
end

def local_manifest_group_type_id
  Card::LocalScriptManifestGroupID
end

def refresh_asset
  update_asset_output if asset_output_needs_refresh?
end

def asset_output_needs_refresh?
  !asset_output_updated_at || source_changed?(since: asset_output_updated_at)
end

def asset_output_updated_at
  asset_output_card&.file_updated_at
end

format :html do
  view :javascript_include_tag, cache: :never do
    [remote_include_tags, local_include_tag].flatten.compact.join "\n"
  end

  def local_include_tag
    return unless local_url

    javascript_include_tag local_url
  end

  def remote_include_tags
    map_remote_items do |tag_args|
      javascript_include_tag tag_args.delete("src"), tag_args
    end
  end

  def local_url
    card.asset_output_url
  end
end
