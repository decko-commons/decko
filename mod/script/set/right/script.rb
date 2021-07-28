include_set Abstract::Pointer

def ok_to_read
  true
end

def refresh_output force=false
  item_cards.each do |item_card|
    item_card.try :refresh_output, force
  end
end

def regenerate_machine_output
  item_cards.each do |item_card|
    item_card.try :regenerate_machine_output
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
