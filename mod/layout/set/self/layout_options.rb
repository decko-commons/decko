def item_names _args={}
  Card.search(type: :layout) + Card::Layout.built_in_layouts
end
