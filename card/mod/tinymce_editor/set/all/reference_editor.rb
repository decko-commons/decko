# shared helper methods for link editor and nest editor

format :html do
  def tinymce_id
    params[:tinymce_id]
  end

  def apply_tm_snippet_data snippet
    data = { "data-tinymce-id": tinymce_id }
    apply_tm_snippet_param :start, :start, data, params[:tm_snippet_data]
    apply_tm_snippet_param :raw, :size, data, snippet.raw.size
    data["data-dismiss"] = "modal" if modal_tm_snippet_editor?
    data
  end

  def modal_tm_snippet_editor?
    @tm_snippet_editor_mode != :overlay
  end

  def apply_tm_snippet_param param_suffix, key_suffix, data, value
    if params[:"tm_snippet_#{param_suffix}"].present?
      data[:"data-tm-snippet-#{key_suffix}"] = value
    end
  end
end
