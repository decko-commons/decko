include_set Abstract::Pointer

abstract_basket :item_codenames

def content
  item_codenames.map do |codename|
    Card.fetch_name codename
  end.compact.to_pointer_content
end
