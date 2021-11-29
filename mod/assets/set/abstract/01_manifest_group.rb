attr_accessor :group_name

format :html do
  view :core do
    list_group card.item_names
  end
end
