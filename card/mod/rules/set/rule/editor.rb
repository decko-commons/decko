format :html do
  attr_accessor :rule_context

  view :rule_edit, cache: :never, unknown: true,
                   wrap: { modal: { size: :large,
                                    title: :edit_rule_title,
                                    footer: "" } } do
    current_rule_form form_type: :modal
  end

  view :rule_help, unknown: true, perms: :none, cache: :never do
    wrap_with :div, class: "alert alert-info rule-instruction" do
      rule_based_help
    end
  end

  view :rule_bridge_link, unknown: true do
    opts = bridge_link_opts(class: "edit-rule-link nav-link",
                            "data-toggle": "pill",
                            "data-cy": "#{setting_title.to_name.key}-pill")
    opts[:path].delete(:layout)
    link_to_view(:overlay_rule, (setting_title + short_help_text), opts)
  end

  def edit_link_view
    :rule_edit
  end

  def edit_rule_title
    output [
      wrap_with(:h5, setting_title, class: "title font-weight-bold"),
      render_overlay_rule_help
    ]
  end

  def current_rule force_reload=true
    @current_rule = nil if force_reload
    @current_rule ||= begin
      rule = determine_current_rule
      reload_rule rule
    end
  end

  def determine_current_rule
    existing = find_existing_rule_card
    return existing if existing

    Card.new name: "#{Card[:all].name}+#{card.rule_user_setting_name}"
  end

  def quick_editor
    if card.right.codename == :default
      @edit_rule_success = {}
      rules_type_formgroup
    else
      rule_content_formgroup
    end
  end

  def setting_title
    card.name.tag.tr "*", ""
  end

  def short_help_text
    "<div class=\"help-text\">#{card.short_help_text}</div>"
  end

  def reload_rule rule
    return rule unless (card_args = params[:card])

    if card_args[:name] && card_args[:name].to_name.key != rule.key
      Card.new card_args
    else
      rule = rule.refresh
      rule.assign_attributes card_args
      rule.include_set_modules
    end
  end

  def rule_set_description
    card.rule_set.follow_label
  end

  def rules_type_formgroup
    return unless card.right.rule_type_editable

    success = @edit_rule_success
    wrap_type_formgroup do
      type_field(
        href: path(mark: success[:id], view: :rule_form, type_reload: true), # view: success[:view]
        class: "type-field rule-type-field live-type-field",
        "data-remote" => true
      )
    end
  end

  def rule_content_formgroup
    formgroup "Content", editor: "content", help: false do
      content_field true
    end
  end

  def current_set_key
    card.new_card? ? Card.quick_fetch(:all).name.key : card.rule_set_key
  end

  private

  def find_existing_rule_card
    # self.card is a POTENTIAL rule; it quacks like a rule but may or may not
    # exist.
    # This generates a prototypical member of the POTENTIAL rule's set
    # and returns that member's ACTUAL rule for the POTENTIAL rule's setting
    if card.new_card?
      if (setting = card.right)
        card.set_prototype.rule_card setting.codename, user: card.rule_user
      end
    else
      card
    end
  end
end
