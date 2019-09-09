def clean_html?
  false
end

def diff_args
  { diff_format: :raw }
end

format do
  view :one_line_content do
    raw_one_line_content
  end

  def chunk_list
    :references
  end
end

format :html do
  def input_type
    :ace_editor
  end

  view :one_line_content, wrap: {} do
    raw_one_line_content
  end
end
