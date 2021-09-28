include_set Type::List

def ok_to_read
  true
end

def refresh_output force: false
  item_cards.each do |item_card|
    # puts "refreshing #{item_card.name}".yellow
    item_card.try :refresh_output, force: force
  end
end

format :html do
  view :javascript_include_tag do
    card.item_cards.map do |script|
      script.format(:html).render :javascript_include_tag
    end
  end

  def raw_help_text
    "JavaScript (or CoffeeScript) for card's page."
  end
end
