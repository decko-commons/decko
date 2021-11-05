include_set Abstract::Paging
include_set Abstract::Items

def diff_args
  { diff_format: :pointer }
end

def count
  item_strings.size
end

def each_item_name_with_options _content=nil
  item_names.each { |name| yield name, {} }
end

private

def each_reference_out
  item_names.each { |name| yield name, Card::Content::Chunk::Link::CODE }
end
