include_set Abstract::Machine
include_set Abstract::MachineInput
include_set Abstract::AssetList

machine_input { standard_machine_input }
store_machine_output filetype: "js"

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

def standard_machine_input
  item_cards.map do |mcard|
    js = mcard.format(:js)._render_core
    js = mcard.compress_js js if minimize?
    "// #{mcard.name}\n#{js}"
  end.join "\n"
end

format :html do
  view :javascript_include_tag do
    javascript_include_tag card.machine_output_url
  end
end
