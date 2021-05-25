def group_name
  codename.to_s.sub(/^.+__/, "")
end

def relative_paths
  paths
end

format :html do
  view :core do
    list_group card.item_names
  end
end
