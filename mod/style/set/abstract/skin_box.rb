format :html do
  view :box do
    class_up "box-middle", "p-0"
    voo.hide :customize_button, :box_middle
    super()
  end

  view :box_bottom, template: :haml

  view :customize_button, cache: :never do
    customize_button
  end

  def customize_button target: parent&.card, text: "Apply and customize"
    return "" unless card.codename.present?

    theme = card.codename.match(/^(?<theme_name>.+)_skin$/).capture(:theme_name)
    link_to_card target, text,
                 path: { action: :update, card: { content: "[[#{card.name}]]" },
                         customize: true, theme: theme },
                 class: "btn btn-sm btn-outline-primary mr-2"
  end

  view :box_middle do
    field_nest :image, view: :full_width, size: :large if card.fetch :image
  end

  def select_button target=parent.card
    link_to_card target, "Apply",
                 path: { action: :update, card: { content: "[[#{card.name}]]" } },
                 class: "btn btn-sm btn-primary"
  end
end
