%i[open open_content titled titled_content].each do |viewname|
  view viewname, unknown: true do
    voo.show :comment_box
    super()
  end
end

view :core, unknown: true do
  output [super(), render_comment_box(optional: :hide)]
end

view :input do
  in_multi_card_editor? ? comment_box : super()
end
