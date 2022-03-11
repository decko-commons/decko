format :html do
  def autocomplete_field item, options_card_name, extra_classes=""
    haml :autocomplete_input,
         item: item, options_card: options_card_name,
         extra_classes: extra_classes
  end

  def name_autocomplete_field item, extra_classes=""
    # select_tag "autocomplete_#{card.key}", "", class: "_select2autocomplete"
    text_field_tag "pointer_item", item,
                   class: "pointer-item-text form-control _autocomplete #{extra_classes}",
                   "data-options-card": %i[all by_name].to_name
  end
end
