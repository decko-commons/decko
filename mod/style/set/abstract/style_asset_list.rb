# A list of styles defined by a manifest group or a "style" asset folder.
# Usually part of a mod_style_assets card
include_set Abstract::AssetInputter, input_format: :scss
include_set Abstract::AssetList

format :scss do
  view :core do
    card.render_items_and_compress :scss
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

