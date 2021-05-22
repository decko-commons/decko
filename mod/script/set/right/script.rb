def ok_to_read
  true
end

view :javascript_include_tag do
  item_cards.map do |script|
    script.format(:html).render :javascript_include_tag
  end
end

def update_if_source_file_changed
  item_cards.each do |item_card|
    item_card.try(:update_if_source_file_changed)
  end
end

format :html do
  def raw_help_text
    "JavaScript (or CoffeeScript) for card's page."
  end
end
