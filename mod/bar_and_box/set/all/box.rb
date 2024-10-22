view :box, template: :haml, cache: :yes do
  voo.hide :menu
end

view :box_top do
  render_title_link
end

view :box_middle do
  _render_content
end

view :box_bottom do
  [_render_creator_credit,
   _render_updated_by]
end
