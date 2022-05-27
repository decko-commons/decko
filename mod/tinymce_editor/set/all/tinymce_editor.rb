basket[:script_calls]["setTinyMCEConfig"] = :tinymce_config
basket[:list_input_options] << "tinymce editor"

format :html do
  def tinymce_config
    Card::Rule.global_setting :tiny_mce
  end

  def tinymce_editor_input
    text_area :content, rows: 3, class: "tinymce-textarea d0-card-content",
                        id: unique_id
  end
end
