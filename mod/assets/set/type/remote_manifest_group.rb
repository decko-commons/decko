include_set Abstract::ReadOnly
include_set Abstract::ManifestGroup

basket[:non_createable_types] << :remote_manifest_group

def local?
  @local = false
end

def minimize?
  @minimize = false
end

def paths
  return [] unless left

  left.manifest_group_items group_name
end

def item_names _content=nil
  paths
end

def content
  paths.join "\n"
end

format :html do
  view :javascript_include_tag, cache: :never do
    paths.map do |path|
      javascript_include_tag path
    end.join("\n")
  end

  view :stylesheet_include_tag do
    paths.map do |path|
      tag "link", href: path, media: "all", rel: "stylesheet", type: "text/css"
    end.join("\n")
  end
end
