include_set Abstract::AssetList

def paths
  return [] unless (path = left&.assets_path)

  relative_paths.map { |child| ::File.join path, child }
end

def relative_paths
  return [] unless (path = left&.assets_path)

  Dir::children path
end

def item_name_to_path name
  ::File.join base_path, name
end

def base_path
  left&.assets_path
end
