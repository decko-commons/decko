include_set Abstract::AssetInputter, input_format: :css
include_set Abstract::AssetList

format :css do
  view :core do
    card.render_items_and_compress :css
  end
end

def new_asset_constants path
  if path.ends_with? ".scss"
    scss_constants
  elsif path.ends_with? ".css"
    css_constants
  end
end

def scss_constants
  { type_id: ScssID, set_module: Abstract::AssetScss }
end

def css_constants
  { type_id: CssID, set_module: Abstract::AssetCss }
end

format :html do
  view :stylesheet_include_tag do
    stylesheet_include_tag card.asset_output_url
  end
end
