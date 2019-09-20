format :html do
  def quick_edit
    card.left.prototype_default_card.try(:show_content_options?) ? super : ""
  end
end