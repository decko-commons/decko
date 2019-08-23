def clean_html?
  false
end

def diff_args
  { diff_format: :raw }
end

format do
  view :one_line_content do
    ""
  end

  def chunk_list
    :references
  end
end

format :html do
  def editor
    :ace_editor
  end
end
