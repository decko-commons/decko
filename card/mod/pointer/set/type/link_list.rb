include_set Abstract::Pointer

def item_names
  reference_chunks.map(&:referee_name)
end

def item_titles
  reference_chunks.map do |chunk|
    chunk.options[:title] || chunk.referee_name
  end
end

format do
  def chunk_list
    :references
  end
end

format :html do
  def editor
    :link_list
  end

  view :link_list_input, cache: :never do
    link_list_input
  end

  def link_list_input args={}
    items = items_for_input args[:item_list]
    extra_class = "pointer-link-list-ul"
    ul_classes = classy "pointer-link-list-editor", extra_class
    haml :link_list_input, items: items, ul_classes: ul_classes,
                           options_card: options_card_name
  end
end
