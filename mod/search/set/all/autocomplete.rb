format :html do
  def autocomplete_field item, options_card_name, extra_classes=""
    haml :autocomplete_input,
         item: item, options_card: options_card_name,
         extra_classes: extra_classes
  end

  def name_autocomplete_field item, extra_classes=""
    haml :autocomplete_input,
         item: item, options_card: [:all, :by_name],
         extra_classes: extra_classes
  end
end
