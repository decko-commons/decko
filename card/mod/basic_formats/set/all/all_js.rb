
format :js do
  def default_item_view
    :core
  end

  view :include_tag do
    %(\n#{javascript_include_tag page_path(card.name)}\n )
  end
end
