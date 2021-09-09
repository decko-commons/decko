include_set Abstract::AssetInputter, input_format: :js
include_set Abstract::AssetList

format :js do
  view :core do
    render_items_and_compress :js
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
