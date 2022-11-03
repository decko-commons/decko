include_set Abstract::List

def self.included host_class
  basket[host_class.basket_name] = []
end

def item_codenames
  basket[basket_name]
end

def content
  item_codenames.map(&:cardname).compact.to_pointer_content
end
