assign_type :phrase

format :html do
  def quick_edit
    if card.left.prototype_default_card&.try(:show_content_options?) &&
       card.left.prototype.rule_card(:input_type)&.supports_content_option_view?
      super
    else
      ""
    end
  end
end
