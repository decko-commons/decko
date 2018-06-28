view :box, template: :haml

view :box_top do
  render_title
end

view_for_override :box_middle
view_for_override :box_bottom
k