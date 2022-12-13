format :html do
  def bridge_rule_set_selection
    wrap_with :div, class: "set-list _set-editor" do
      bridge_rule_set_formgroup
    end
  end

  def bridge_rule_set_formgroup
    tag = @rule_context.rule_user_setting_name
    narrower = []

    wrap_with :div, class: "col-xs-6 mt-3 mb-5" do
      rule_set_options.reverse.map do |set_name, state|
        RuleSetRadio.new(self, set_name, tag, state).html narrower
      end
    end
  end

  def rule_set_options
    @rule_set_options ||= @rule_context.set_options
  end
end
