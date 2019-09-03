format do
  view :core do
    link_to_resource _render_raw, render_title
  end

  view :url_link do
    link_to_resource _render_raw
  end
end

format :html do
  def input_type
    :text_field
  end
end
