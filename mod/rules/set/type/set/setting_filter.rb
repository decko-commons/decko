format :html do
  view :filtered_accordion_rule_list do
    filtered_rule_list :accordion_rule_list
  end
  def filtered_rule_list view, *filter_args
      [
        setting_filter(view, *filter_args),
        render(view)
      ]
  end

  def setting_filter view, selected_category=:common, set_options=nil, path_opts={}
    form_tag path(path_opts.merge(view: view)),
             remote: true, method: "get", role: "filter",
             "data-slot-selector": ".card-slot._setting-list",
             class: classy("nodblclick slotter") do
      output [
               filter_buttons(selected_category)
      ].flatten
    end
  end

  def filter_buttons selected=:all
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
        <label class="btn btn-outline-primary" for="#{name}">#{label}</label>
    HTML
  end
end
