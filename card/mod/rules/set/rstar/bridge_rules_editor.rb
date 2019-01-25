format :html do
  view :overlay_rule, cache: :never, tags: :unknown_ok do
    return "not a rule" unless card.is_rule?

    current_rule_format = subformat current_rule
    current_rule_format.rule_context = card

    wrap_with_overlay slot: breadcrumb_data("Rule editing", "rules") do
      current_rule_format.rule_form
    end
  end

  def rule_form
    edit_rule_form do
      [
        hidden_tags(success: @edit_rule_success),
        render_rule_form
      ].join
    end
  end

  view :rule_form, cache: :never, tags: :unknown_ok, template: :haml do
  end

  view :overlay_title do
    [wrap_with(:h5, setting_title, class: "title font-weight-bold"),
     render_overlay_rule_help]
  end

  view :overlay_rule_help, tags: :unknown_ok, perms: :none, cache: :never do
    # wrap_with :div, class: "help-text rule-instruction d-flex justify-content-between"
    # do

    # output [wrap_with(:div, rule_based_help), setting_link]
    # end
    popover_link([rule_based_help, setting_link].join(" "))
  end

  def setting_link
    wrap_with :div, class: "ml-auto" do
      link_to_card card.rule_setting_name, " (37 #{card.rule_setting_title} rules)",
                   class: "text-muted", target: "wagn_setting"
    end
  end

  def bridge_rule_set_selection
    wrap_with :div, class: "set-list" do
      bridge_rule_set_formgroup
    end
  end

  def bridge_rule_set_formgroup
    tag = @rule_context.rule_user_setting_name
    narrower = []
    res = bridge_option_list "set" do
      rule_set_options.map do |set_name, state|
        rule_set_radio_button set_name, tag, state, narrower
      end
    end
    res
  end

  def bridge_option_list _title
    index = -1
    formgroup "", editor: "set", class: "col-xs-6", help: false do
      yield.inject("") do |res, radio|
        index += 1
        # TODO
        if false # index.in? [2,3]
          wrap_with(:li, radio, class: "radio") + res
        else
          wrap_with :ul do
            wrap_with(:li, (radio + res), class: "radio")
          end
        end
      end
    end
  end

  def rule_set_options
    @rule_set_options ||= @rule_context.set_options
  end

  def selected_rule_set
    if @rule_set_options.length == 1 then true
    elsif params[:type_reload]       then card.rule_set_name
    else                                  false
    end
  end

  def rule_set_radio_button set_name, tag, state, narrower
    warning = narrower_rule_warning narrower, state, set_name
    checked = checked_set_button? set_name, selected_rule_set
    rule_radio set_name, state do
      radio_text = "#{set_name}+#{tag}"
      radio_button :name, radio_text, checked: checked, warning: warning
    end
  end
end
