include_set Abstract::Machine
include_set Abstract::MachineInput
include_set Abstract::AssetList

machine_input { standard_machine_input }
store_machine_output filetype: "css"

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

def standard_machine_input
  item_cards.map do |mcard|
    css = mcard.format(:css)._render_core
    css = mcard.compress_css css if minimize?
    "// #{mcard.name}\n#{css}"
  end.join "\n"
end

format :html do
  view :stylesheet_include_tag do
    stylesheet_include_tag card.machine_output_url
  end
end

