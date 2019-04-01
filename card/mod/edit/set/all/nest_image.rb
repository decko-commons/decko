format :html do
  view :nest_image, wrap: :modal do
    nest card.autoname(card.name.field("image1")), view: :new, success: { view: "sdfs" }
  end
end
