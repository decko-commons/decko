def cql_content
  { referred_to_by: "_" }
end

def item_cards args={}
  standard_item_cards args
end

def count
  item_strings.size
end
