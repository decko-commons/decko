format do
  def chunk_list
    :references
  end
end

format :html do
  def header_field text
    content_tag :span, text, class: "form-control border-0 control-label"
  end
end
