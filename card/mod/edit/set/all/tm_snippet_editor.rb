# shared helper methods for link editor and nest editor

format :html do
  def tinymce_id
    params[:tinymce_id]
  end

  def apply_tm_snippet_data snippet
    data = { "data-tinymce-id": tinymce_id }
    data["data-tm-snippet-start".to_sym] = params[:tm_snippet_start] if params[:tm_snippet_start].present?
    data["data-tm-snippet-size".to_sym] = snippet.raw.size if params[:tm_snippet_raw].present?
    data
  end
end