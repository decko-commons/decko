format :html do
  def quick_editor
    @submit_on_change = true
    super
  end

  def raw_help_text
    "edit interface for list cards"
  end

  def option_label_text option_name
    super.downcase
  end
end
