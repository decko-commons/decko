include_set Abstract::Paging
include_set Abstract::Items

def diff_args
  { diff_format: :pointer }
end

def count
  item_strings.size
end
