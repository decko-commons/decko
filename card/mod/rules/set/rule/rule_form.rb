format :html do
  view :rule_form, cache: :never, tags: :unknown_ok do
    @success_view ||= :open
    @rule_context ||= card
    @form_type ||= :overlay

    wrap do
      edit_rule_form @success_view do
        [
          hidden_tags(success: @edit_rule_success),
          haml(:rule_form)
        ].join
      end
    end
  end

  def form_type
    @form_type || :overlay
  end

  def current_rule_form success_view: :overlay_rule, form_type: :overlay
    current_rule_format = subformat current_rule
    current_rule_format.rule_form success_view, card, form_type
  end

  def rule_form success_view, rule_context, form_type=:overlay
    validate_form_type form_type

    @rule_context = rule_context
    @form_type = form_type
    @success_view = success_view

    render_rule_form
  end

  def validate_form_type form_type
    return if form_type.in? %i[overlay modal]

    raise "invalid rule_form type: #{form_type}; has to be overlay or modal"
  end

  def edit_rule_form success_view, &block
    @rule_context ||= card
    @edit_rule_success = edit_rule_success(success_view)
    action_args = { action: :update, no_mark: true }
    card_form action_args, rule_form_args, &block
  end

  def rule_form_args
    { class: "card-rule-form", "data-slotter-mode": "update-origin" }
  end

  def edit_rule_success view="overlay_rule"
    { id: @rule_context.name.url_key,
      view: view }
  end
end
