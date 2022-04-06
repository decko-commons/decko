# card, that lists all styles that belong to one mod, for example:
# "mod: bootstrap+*style"

include_set Abstract::AssetInputter, input_format: :scss
include_set Abstract::ModAssets

def subpath
  "style"
end

def folder_group_type_id
  ::Card::LocalStyleFolderGroupID
end

def local_manifest_group_type_id
  ::Card::LocalStyleManifestGroupID
end

format :html do
  view :stylesheet_include_tag do
    card.item_cards.map do |icard|
      nest icard, view: :stylesheet_include_tag
    end.join("\n")
  end

  view :remote_include_tags do
    map_remote_items do |tag_args|
      tag "link",
          href: tag_args.delete("src"),
          media: "all", rel: "stylesheet", type: "text/css"
    end
  end
end

def asset_input_needs_refresh?
  !asset_input_updated_at || source_changed?(since: asset_input_updated_at)
end

def asset_input_updated_at
  asset_input_card&.updated_at
end
