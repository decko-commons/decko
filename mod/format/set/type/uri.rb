format do
  view :title_link do
    link_to_resource _render_raw, render_title_no_link
  end

  view :url_link do
    link_to_resource _render_raw
  end
end

format :html do
  view :core do
    render_title_link
  end

  def input_type
    :text_field
  end
end
