format :html do
  def set_select set_list_type, setting_list_view=:filtered_accordion_rule_list, path_opts={}
    # return filter_text.html_safe unless set_options

    card_select card.set_list(set_list_type), setting_list_view, path_opts, "Select set"
  end

  def set_select_tag set_options=:related
    select_tag(:mark, set_select_options(set_options),
               class: "_submit-on-select form-control _close-rule-overlay-on-select",
               "data-minimum-results-for-search": "Infinity",
               "data-placeholder": "Select set",
               "data-select2-id": "#{unique_id}-#{Time.now.to_i}")
  end

  view :card_select, wrap: :slot do
    card_select card.set_list(:related), :filtered_accordion_rule_list, {}, "Select set"
  end

  def card_select cards, view, path_opts={}, placeholder=nil
    options = cards.map(&:label_and_url_key)
    options.unshift("") if placeholder
    form_tag path(path_opts.merge(view: view, mark: "")),
                     remote: true, method: "get", role: "filter",
                     "data-slot-selector": ".card-slot._fixed-slot",
                     class: "nodblclick slotter" do
      output [
        select_tag(:mark, options_for_select(options),
                   class: "_submit-on-select form-control _close-rule-overlay-on-select",
                   "data-minimum-results-for-search": "Infinity",
                   "data-placeholder": "Select set",
                   "data-select2-id": "#{unique_id}-#{Time.now.to_i}"),
        content_tag(:div, "", class: "card-slot _fixed-slot")
             ]
      end
  end

  private

  def filter_text
    wrap_with :span, class: "mx-2 small" do
      "rules that apply to #{_render_set_label.downcase}" # LOCALIZE
    end
  end

  def set_select_options set_list_type=:self
    options = card.set_list(set_list_type).map(&:label_and_url_key)
    options.unshift("")
    options_for_select(options, selected_set)
  end

  def selected_set
    return nil
    params[:set]
  end

  def set_alert set_list_type
    wrap_with :div, class: "alert alert-info" do
      [
        "Rules apply to:",
        card.set_list(set_list_type).first.name,
        link_to_card(card, "More sets and settings", path: { view: :rules }, target: "_blank")
      ]
    end
  end
end

def set_list set_list_type
  case set_list_type
  when :related
    related_sets(true)
  when :broader
    broader_sets
  else
    [Card[self, :self]]
  end
end


