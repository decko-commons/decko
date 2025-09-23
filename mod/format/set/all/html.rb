format :html do
  delegate :class_up, :class_down, :with_class_up, :without_upped_class, :classy,
           to: :voo

  view :type, unknown: true do
    link_to_card card.type_card, nil, class: "cardtype"
  end

  view :type_info do
    return unless card.type_code != :basic

    wrap_with :span, class: "type-info float-end" do
      link_to_card card.type_name, nil, class: "navbar-link"
    end
  end

  def default_nest_view
    Cardio.config.default_html_view
  end

  def default_item_view
    :bar
  end
end

format do
  # Sanitizer that strips all html tags
  def sanitize_html value
    return if value.blank?
    (@full_sanitizer ||= Rails::Html::FullSanitizer.new).sanitize(value.to_s).presence
  end
end
