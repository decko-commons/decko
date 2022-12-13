def add_autocomplete_ok?
  new_card? && name.valid? && !virtual? && ok?(:create)
end

format :html do
  view :goto_autocomplete_item do
    autocomplete_item :goto, goto_autocomplete_icon, autocomplete_label
  end

  view :add_autocomplete_item, unknown: true do
    autocomplete_item :add, icon_tag(:add), autocomplete_label
  end

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

  def add_autocomplete_item_path
    path
  end

  private

  def autocomplete_item type, icon, label
    haml :autocomplete_item, type: type, icon: icon, label: label
  end

  def goto_autocomplete_icon
    if card.fetch :image
      field_nest :image, view: :core, size: :small
    else
      icon_tag :arrow_forward
    end
  end

  def autocomplete_label
    card.name
  end
end
