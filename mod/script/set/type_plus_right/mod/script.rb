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
    [card.remote_group_urls, local_url].flatten.compact.map do |url|
      javascript_include_tag url
    end.join "\n"
  end

  def local_url
    card.asset_output_url
  end
end