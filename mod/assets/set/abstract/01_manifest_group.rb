attr_accessor :group_name
attr_accessor :relative_paths

format :html do
  view :core do
    list_group card.item_names
  end
end
