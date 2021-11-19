basket[:script_config][:tiny_mce] = "setTinyMCEConfig"
basket[:list_input_options] << "tinymce editor"

format :html do
  def tinymce_editor_input
    text_area :content, rows: 3, class: "tinymce-textarea d0-card-content",
                        id: unique_id
  end
end
