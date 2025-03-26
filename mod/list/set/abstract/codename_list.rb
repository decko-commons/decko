include_set Abstract::List

def self.included host_class
  basket[host_class.basket_name] = []
end

def item_codes
  basket[basket_name]
end

def content
  item_codes.map(&:cardname).compact.to_pointer_content
end
