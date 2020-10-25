def checked?
  content == "1"
end

view :core do
  case card.content.to_i
  when 1 then tr(:yes)
  when 0 then tr(:no)
  else
    "?"
  end
end

format :html do
  view :input do
    toggle
  end

  view :labeled_editor do
    toggle + toggle_label
  end

  def toggle
    check_box :content
  end

  def toggle_label
    label :content, card.name.tag
  end

  def one_line_content
    short_content
  end

  def short_content
    render_core
  end
end
