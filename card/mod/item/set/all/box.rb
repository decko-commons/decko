view :box, template: :haml

view :box_top do
  render_title_link
end

view_for_override :box_middle
view_for_override :box_bottom
