include_set Abstract::Pointer

def each_reference_out
  item_names.each do |name|
    yield(name, Card::Content::Chunk::Link::CODE)
  end
end

format :html do
  view :view_list do
    %i[info_bar bar box closed titled labeled].map do |view|
      voo.items[:view] = view
      wrap_with :p, [content_tag(:h3, "#{view} items"), render_content]
    end
  end
end
