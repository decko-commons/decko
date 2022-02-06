include_set Abstract::Items
include_set Abstract::ReferenceList

def raw_item_strings content
  reference_chunks(content).map(&:referee_raw_name)
end

def item_options
  nest_chunks.map(&:raw_options)
end

def items_content array
  standardized_items(array).join "\n"
end

format :html do
  def input_type
    :nest_list
  end

  view :nest_list_input, cache: :never do
    nest_list_input
  end

  view :input do
    _render_hidden_content_field + super()
  end

  def items_for_input items=nil
    items ||= card.item_names context: :raw
    items.empty? ? [["", ""]] : items.zip(card.item_options)
  end

  def nest_list_input args={}
    items = items_for_input args[:item_list]
    extra_class = "_nest-list-ul"
    ul_classes = classy "pointer-list-editor", extra_class
    haml :nest_list_input, items: items, ul_classes: ul_classes
  end
end
