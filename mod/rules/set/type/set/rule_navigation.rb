format :html do
  def filtered_rule_list view, *filter_args
      [
        rules_filter(view, *filter_args),
        render(view)
      ]
  end

  def rules_filter view, selected_category=nil, set_options=nil, path_opts={}
    form_tag path(path_opts.merge(view: view)),
             remote: true, method: "get", role: "filter",
             "data-slot-selector": ".card-slot.rule-list",
             class: classy("nodblclick slotter") do
      output [
        set_select(set_options),
        setting_filter(selected_category)
      ].flatten
    end
  end


  def set_select set_options
    return filter_text.html_safe unless set_options
    wrap_with :div, class: "form-group" do
      [
        content_tag(:label, "Set"),
        set_select_tag(set_options)
      ]
    end
  end

  def setting_filter selected=:all
    wrap_with :div, class: "my-4 _setting-filter" do
      [
        content_tag(:label, "Settings"),
        filter_radio(:all, "All", selected == :all),
        filter_radio(:common, "Common", selected == :common),
        filter_radio(:field, "Field", selected == :field_related),
        filter_radio(:recent, "Recent", selected == :recent)
      ]
    end
  end

  def filter_radio name, label, checked=false
    <<-HTML.strip_heredoc
        <input type="radio" class="btn-check _setting-category" name="options" id="#{name}" autocomplete="off" #{'checked' if checked}>
        <label class="btn btn-outline-secondary" for="#{name}">#{label}</label>
    HTML
  end

  def filter_text
    wrap_with :span, class: "mx-2 small" do
      "rules that apply to #{_render_set_label.downcase}" # LOCALIZE
    end
  end

  def set_select_tag set_options=:related
    select_tag(:mark, set_select_options(set_options),
               class: "_submit-on-select form-control _close-rule-overlay-on-select",
               "data-minimum-results-for-search": "Infinity",
               "data-select2-id": "#{unique_id}-#{Time.now.to_i}")
  end

  def selected_set
    params[:set]
  end

  def set_select_options set_options
    options =
      if set_options == :related
        related_set_options
      else
        [[card.label, card.name.url_key]]
      end
    options_for_select(options, selected_set)
  end

  def related_set_options
    card.related_sets(true).map do |name, label|
      [label, name.to_name.url_key]
    end
  end
end
