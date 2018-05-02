format :html do
  view :thumbnail, template: :haml do
    voo.hide :customize_button, :thumbnail_image
  end

  view :customize_button, cache: :never do
    customize_button
  end

  def customize_button target = parent.card
    return "" unless card.codename.present?
    theme = card.codename.match(/^(?<theme_name>.+)_skin$/).capture(:theme_name)
    link_to_card target, "Customize",
                 path: { action: :update, card: { content: "[[#{card.name}]]" },
                         customize: true, theme: theme },
                 class: "btn btn-sm btn-outline-primary"
  end

  view :thumbnail_image do
    field_nest(:image, view: :full_width)
  end

  def select_button target = parent.card
    link_to_card target, "Select",
                 path: { action: :update, card: { content: "[[#{card.name}]]" } },
                 class: "btn btn-sm btn-outline-primary"
  end
end
