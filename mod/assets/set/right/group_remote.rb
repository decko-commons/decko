include_set Abstract::ReadOnly
include_set Abstract::ManifestGroup

def virtual?
  new?
end

def local?
  @local = false
end

def minimize?
  @minimize = false
end

def item_configs
  return @item_configs if @item_configs

  @item_configs = left.manifest_group_items("remote") || []
end

def urls
  item_configs.map { |path| path["src"] }
end

def content
  urls.join "\n"
end

def map_items
  item_configs.map { |config| yield config.clone }
end

format :html do
  delegate :urls, to: :card

  view :core do
    list_group urls
  end

  view :javascript_include_tag, cache: :never do
    urls.map do |path|
      javascript_include_tag path
    end.join("\n")
  end

  view :stylesheet_include_tag do
    urls.map do |path|
      tag "link", href: path, media: "all", rel: "stylesheet", type: "text/css"
    end.join("\n")
  end
end
