def item_names _args={}
  Card.search(type: :layout_type, return: :name) + Card::Layout.built_in_layouts
end
