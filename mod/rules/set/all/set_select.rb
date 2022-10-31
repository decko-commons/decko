Rulformat :html do
  def set_select set_options
    return filter_text.html_safe unless set_options
    wrap_with :div, class: "form-group" do
      [
        content_tag(:label, "Set"),
        set_select_tag(set_options)
      ]
    end
  end

  def set_select_tag set_options=:related
    select_tag(:mark, set_select_options(set_options),
               class: "_submit-on-select form-control _close-rule-overlay-on-select",
               "data-minimum-results-for-search": "Infinity",
               "data-select2-id": "#{unique_id}-#{Time.now.to_i}")
  end

  private

  def filter_text
    wrap_with :span, class: "mx-2 small" do
      "rules that apply to #{_render_set_label.downcase}" # LOCALIZE
    end
  end

  def set_select_options set_list_type
    options = set_list(set_list_type).map(&:label_and_url_key)
    options_for_select(options, selected_set)
  end

  def selected_set
    params[:set]
  end

  def set_list set_list_type
    case set_list_type
    when :related
      cards.related_sets(true)
    when :broader
      card.broader_sets
    else
      [Card.fetch[card, :self]]
    end
  end

  def set_alert set_list_type
    return filter_text.html_safe unless set_list_type

    wrap_with :div, class: "alert alert-info" do
      [
        "Rules apply to:",
        set_list(set_list_type).first.name,
        link_to_card(self, "More sets and settings", path: { view: :rules }, target: "_blank")
      ]
    end
  end
end


