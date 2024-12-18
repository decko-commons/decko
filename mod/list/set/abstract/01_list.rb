include_set Abstract::Paging
include_set Abstract::Items

# for override
# if false, item names that match cardnames will
# NOT be treated like references to those cards
def item_references?
  true
end

def diff_args
  { diff_format: :pointer }
end

def count
  item_strings.size
end

def standardize_content value
  value = item_strings(content: value) unless value.is_a? Array
  super
end

def each_item_name_with_options _content=nil
  item_names.each { |name| yield name, {} }
end

def swap_names old_name, new_name
  item_strings.map do |string|
    if string.match?(/^[:~]/)
      string
    else
      string.to_name.swap old_name, new_name
    end
  end
end

format :html do
  view :view_list do
    %i[bar box closed titled labeled].map do |view|
      voo.items[:view] = view
      wrap_with :p, [content_tag(:h3, "#{view} items"), render_content]
    end
  end
end

private

def chunk_class
  Card::Content::Chunk::Link
end

def each_reference_out
  return unless item_references?

  item_names.each { |name| yield name, chunk_class::CODE }
end
