view :box, template: :haml

view :box_top do
  render :title
end

view_for_override :box_middle
view_for_override :box_bottom