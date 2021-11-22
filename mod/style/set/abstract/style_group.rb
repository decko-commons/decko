# A list of styles defined by a manifest group or a "style" asset folder.
# Usually part of a mod_style_assets card
include_set Abstract::AssetGroup

def asset_input_content
  format(:scss).render_core
end

format :scss do
  view :core do
    card.item_cards.compact.map do |mcard|
      mcard.format(:scss)._render_core
    end.join "\n"
  end
end

def valid_file_extensions
  %w[css scss]
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
