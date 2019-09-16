format :html do
  def quick_editor
    @submit_on_change = true
    super
  end

  def default_input_type
    :radio
  end

  def raw_help_text
    "edit interface for list cards"
  end

  def option_label_text option_name
    super.downcase
  end
end

def supports_content_options?
  content.in? ["checkbox", "radio", "filtered list"]
end