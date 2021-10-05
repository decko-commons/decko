include_set Abstract::AssetList


def asset_input_content
  format(:js).render_core
end

format :js do
  view :core do
    card.render_items_and_compress :js
  end
end

def new_asset_constants path
  if path.ends_with? ".js.coffee"
    coffeescript_constants
  elsif path.ends_with? ".js"
    javascript_constants
  end
end

def coffeescript_constants
  { type_id: CoffeeScriptID, set_module: Abstract::AssetCoffeeScript }
end

def javascript_constants
  { type_id: JavaScriptID, set_module: Abstract::AssetJavaScript }
end

format :html do
  view :javascript_include_tag do
    javascript_include_tag card.asset_output_url
  end
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
