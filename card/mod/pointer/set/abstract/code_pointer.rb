include_set Abstract::Pointer

abstract_basket :item_codenames

module ClassMethods
  def add_to_codepointer set_module, codename
    if Card::Codename.exist? codename
      set_module.add_to_basket :item_codenames, codename
    end
  end
end

def content
  item_codenames.map do |codename|
    Card.fetch_name codename
  end.compact.to_pointer_content
end
