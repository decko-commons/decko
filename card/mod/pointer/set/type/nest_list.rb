include_set Abstract::Pointer

def raw_item_strings content
  reference_chunks(content).map(&:referee_name)
end

def item_options
  reference_chunks.map do |chunk|
    chunk.options
  end
end

format do
  def chunk_list
    :references
  end
end

format :html do
  def input_type
    :nest_list
  end

  view :nest_list_input, cache: :never do
    nest_list_input
  end

  def items_for_input items=nil
    items ||= card.item_names context: :raw
    items.empty? ? [["", ""]] : items.zip(card.item_options)
  end

  def nest_list_input args={}
    items = items_for_input args[:item_list]
    extra_class = "_nest-list-ul"
    ul_classes = classy "pointer-list-editor", extra_class
    haml :nest_list_input, items: items, ul_classes: ul_classes,
                           options_card: options_card_name
  end
end
