format :html do
  def input_type
    :calendar
  end

  view :core do
    ::Date.parse(card.content).strftime "%B %-d, %Y"
  end
end
