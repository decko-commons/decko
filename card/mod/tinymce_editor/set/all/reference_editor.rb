# shared helper methods for link editor and nest editor

format :html do
  def tinymce_id
    params[:tinymce_id]
  end

  def apply_tm_snippet_data snippet
    data = { "data-tinymce-id": tinymce_id }
    data[:"data-tm-snippet-start"] = tm_param(:start) if tm_param(:start).present?
    data[:"data-tm-snippet-size"] = snippet.raw.size if tm_param(:raw).present?
    data["data-dismiss"] = "modal" if modal_tm_snippet_editor?
    data
  end

  def tm_param key
    params[:"tm_snippet_#{key}"]
  end

  def modal_tm_snippet_editor?
    @tm_snippet_editor_mode != :overlay
  end
end
