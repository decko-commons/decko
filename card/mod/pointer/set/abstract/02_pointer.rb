include_set Abstract::Paging

def diff_args
  { diff_format: :pointer }
end

def count
  all_raw_item_strings.size
end
