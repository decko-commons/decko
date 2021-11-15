include_set Abstract::AssetGroup

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

def valid_file_extensions
  %w[js coffee]
end
