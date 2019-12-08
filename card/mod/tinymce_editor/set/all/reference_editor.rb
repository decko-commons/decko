# shared helper methods for link editor and nest editor

format :html do
  def tinymce_id
    params[:tinymce_id]
  end

  def apply_tm_snippet_data snippet
    data = { "data-tinymce-id": tinymce_id }
    if params[:tm_snippet_start].present?
      data["data-tm-snippet-start".to_sym] = params[:tm_snippet_start]
    end
    if params[:tm_snippet_raw].present?
      data["data-tm-snippet-size".to_sym] = snippet.raw.size
    end
    data["data-dismiss"] = "modal" if modal_tm_snippet_editor?
    data
  end

  def modal_tm_snippet_editor?
    @tm_snippet_editor_mode != :overlay
  end
end
