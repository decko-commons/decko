include_set Abstract::ManifestGroup

def paths
  return [] unless left

  relative_paths.map { |path| ::File.join(base_path, path) } || []
end

def relative_paths
  return [] unless left

  left.manifest_group_items group_name
end

def item_name_to_path name
  ::File.join base_path, name
end

def minimize?
  left.manifest_group_minimize? group_name
end

def base_path
  left&.assets_path
end
