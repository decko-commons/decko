format :html do
  def bridge_rule_set_selection
    wrap_with :div, class: "set-list" do
      bridge_rule_set_formgroup
    end
  end

  def bridge_rule_set_formgroup
    tag = @rule_context.rule_user_setting_name
    narrower = []

    bridge_option_list "Set" do
      rule_set_options.map do |set_name, state|
        RuleSetRadio.new(self, set_name, tag, state).html narrower
      end
    end
  end

  def bridge_option_list title
    index = -1
    formgroup title, input: "set", class: "col-xs-6", help: false do
      yield.inject("") do |res, radio|
        index += 1
        # TODO
        if false  # index.in? [2,3]
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
end
