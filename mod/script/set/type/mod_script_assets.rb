include_set Abstract::ModAssets

def subpath
  "javascript"
end

format :html do
  view :javascript_include_tag do
    card.item_cards.map do |icard|
      nest icard, view: :javascript_include_tag
    end.join("\n")
  end
end
