assign_type :list

def ok_to_read?
  true
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
