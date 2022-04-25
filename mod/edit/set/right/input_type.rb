assign_type :pointer

format :html do
  def quick_editor
    @submit_on_change = true
    super
  end

  def quick_form_opts
    super.merge "data-update-foreign-slot":
                ".card-slot.quick_edit-view.RIGHT-Xcontent_option_view"
  end

  def default_input_type
    :radio
  end

  def raw_help_text
    "edit interface for list cards"
  end

  # def option_label_text option_name
  #   super.downcase
  # end

  def quick_edit
    card.left.prototype_default_card.try(:show_input_type?) ? super : ""
  end
end

def option_names
  left.prototype_default_card&.try(:input_type_content_options) || super
end

def supports_content_option_view?
  item_name.in? ["checkbox", "radio", "filtered list"]
end
