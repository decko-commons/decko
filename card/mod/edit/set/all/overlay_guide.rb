format :html do
  view :overlay_guide,
       cache: :never, unknown: true, template: :haml,
       wrap: { slot: { class: "_overlay d0-card-overlay card nodblclick" } } do
    # TODO: use a common template for this and the nest editor
    # (the common thing is that they both are an overlay of the bridge sidebar)
    #  and maybe make it look more like the overlay on the left with the same close icon
  end
end
