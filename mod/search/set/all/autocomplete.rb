def add_autocomplete_ok?
  new_card? && name.valid? && !virtual? && ok?(:create)
end

format :json do
  def add_autocomplete_item term
    return unless card.add_autocomplete_ok?

    { id: term, href: path(), text: add_autocomplete_item_text }
  end

  private

  def add_autocomplete_item_text
    card.format.render_add_autocomplete_item
  end
end


format :html do
  view :goto_autocomplete_item do
    autocomplete_item goto_autocomplete_icon, autocomplete_label
  end

  view :add_autocomplete_item, unknown: true do
    autocomplete_item icon_tag(:add), autocomplete_label
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


  private

  def autocomplete_item icon, label
    haml :autocomplete_item, icon: icon, label: label
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
