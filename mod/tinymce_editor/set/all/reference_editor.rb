# shared helper methods for link editor and nest editor

format :html do
  def tinymce_id
    params[:tinymce_id]
  end

  private

  def tm_param key
    params[:"tm_snippet_#{key}"]
  end

  def modal_tm_snippet_editor?
    @tm_snippet_editor_mode != :overlay
  end

  def apply_tm_snippet_data snippet
    { "data-tinymce-id": tinymce_id }.tap do |data|
      apply_tm_snippet_vars data, snippet
      apply_tm_data_dismiss data
      apply_tm_data_index data
    end
  end

  def apply_tm_data_dismiss data
    data["data-bs-dismiss"] = "modal" if modal_tm_snippet_editor?
  end

  def apply_tm_data_index data
    data["data-index"] = params["index"] if params["index"].present?
  end

  def apply_tm_snippet_vars data, snippet
    apply_tm_snippet_var(data, :start) { tm_param :start }
    apply_tm_snippet_var(data, :size, :raw) { snippet.raw.size }
  end

  def apply_tm_snippet_var data, varname, paramname=nil
    return unless tm_param(paramname || varname).present?

    data[:"data-tm-snippet-#{varname}"] = yield
  end
end
