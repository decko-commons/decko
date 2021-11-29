attr_accessor :assets_path
attr_accessor :group_name

def paths
  return [] unless (path = assets_path)

  relative_paths.map { |child| ::File.join path, child }
end

def relative_paths
  return [] unless (path = assets_path)

  Dir.chdir(path) do
    Dir.glob search_path
  end
end

def search_path
  File.join "**", "*.{#{valid_file_extensions.join(',')}}"
end

def base_path
  assets_path
end

def minimize?
  @minimize = true
end
