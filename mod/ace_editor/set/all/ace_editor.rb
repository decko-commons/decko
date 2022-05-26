basket[:list_input_options] << "ace editor"
basket[:script_calls]["setAceConfig"] = :ace_config

format :html do
  def ace_config
    Card::Rule.global_setting :ace
  end

  def ace_editor_input
    text_area :content, rows: 5,
                        class: "d0-card-content ace-editor-textarea",
                        "data-ace-mode" => ace_mode
  end

  def ace_mode
    :html
  end
end
