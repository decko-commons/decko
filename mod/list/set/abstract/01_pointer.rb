include_set Abstract::Paging
include_set Abstract::Items

def diff_args
  { diff_format: :pointer }
end

def count
  item_strings.size
end

def standardize_content value
  value = item_strings(content: value) unless value.is_a? Array
  super value
end

def each_item_name_with_options _content=nil
  item_names.each { |name| yield name, {} }
end

def replace_references old_name, new_name
  item_strings.map do |string|
    if string.match?(/^[:~]/)
      string
    else
      string.to_name.swap old_name, new_name
    end
  end
end

private

def chunk_class
  Card::Content::Chunk::Link
end

def each_reference_out
  item_names.each { |name| yield name, chunk_class::CODE }
end
