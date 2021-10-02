view :titled, unknown: true do
  voo.show :comment_box
  super()
end

view :open, unknown: true do
  voo.show :comment_box
  super()
end

view :core, unknown: true do
  output [super(), render_comment_box(optional: :hide)]
end
