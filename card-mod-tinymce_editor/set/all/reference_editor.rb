# shared helper methods for link editor and nest editor

format :html do
  def tinymce_id
    params[:tinymce_id]
  end

  def tm_param key
    params[:"tm_snippet_#{key}"]
  end

  def modal_tm_snippet_editor?
    @tm_snippet_editor_mode != :overlay
  end

  private

  def apply_tm_snippet_data snippet
    { "data-tinymce-id": tinymce_id }.tap do |data|
      apply_tm_snippet_var(data, :start) { tm_param :start }
      apply_tm_snippet_var(data, :size, :raw) { snippet.raw.size }
      data["data-dismiss"] = "modal" if modal_tm_snippet_editor?
      data["data-index"] = params["index"] if params["index"].present?
    end
  end

  def apply_tm_snippet_var data, varname, paramname=nil
    return unless tm_param(paramname || varname).present?

    data[:"data-tm-snippet-#{varname}"] = yield
  end
end
