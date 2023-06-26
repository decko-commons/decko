include_set Abstract::List

def item_codenames
  Cardio.mods.map do |mod|
    "#{mod}_mod"
  end
end

def content
  item_codenames.map(&:cardname).compact.to_pointer_content
end