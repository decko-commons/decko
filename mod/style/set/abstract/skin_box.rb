format :html do
  more  view :box, cache: :yes do
    class_up "box-middle", "p-0"
    voo.hide :customize_button, :box_middle
    super()
  end

  view :box_bottom, template: :haml

  view :customize_button do
    ""
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
