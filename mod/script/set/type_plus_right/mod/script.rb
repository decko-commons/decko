include_set Abstract::AssetOutputter, output_format: :js
include_set Abstract::ModAssets

def make_asset_output_code
  super mod_name
end

def subpath
  "script"
end

def folder_group_type_id
  ::Card::LocalScriptFolderGroupID
end

def local_manifest_group_type_id
  ::Card::LocalScriptManifestGroupID
end

def refresh_asset
  return unless asset_output_needs_refresh?

  update_asset_output
end

def asset_output_needs_refresh?
  !asset_output_updated_at || source_changed?(since: asset_output_updated_at)
end

def asset_output_updated_at
  asset_output_card&.file_updated_at
end

format :html do
  view :javascript_include_tag do
    [remote_include_tags, local_include_tag].flatten.compact.join "\n"
  end

  def local_include_tag
    return unless local_url

    javascript_include_tag local_url
  end

  def remote_include_tags
    remote_items = card.manifest_group_items "remote"
    return unless remote_items

    remote_items.map do |args|
      javascript_include_tag args.delete("src"), args
    end
  end

  def local_url
    card.asset_output_url
  end
end
