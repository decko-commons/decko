format :html do
  attr_accessor :rule_context

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

  view :rule_help, tags: :unknown_ok, perms: :none, cache: :never do
    wrap_with :div, class: "alert alert-info rule-instruction" do
      rule_based_help
    end
  end

  view :show_rule, cache: :never, tags: :unknown_ok do
    return "No Current Rule" if card.new_card?

    voo.items[:view] ||= :link
    output [
             show_rule_set(card.rule_set),
             _render_core
           ]
  end

  def show_rule_set set
    wrap_with :div, class: "rule-set" do
      %(<label>Applies to</label> #{link_to_card set.name, set.label}:)
    end
  end

  view :rule_bridge_link, tags: :unknown_ok do
    opts = bridge_link_opts(class: "edit-rule-link slotter nav-link",
                            "data-toggle": "pill",
                            "data-cy": "#{setting_title.to_name.key}-pill")
    opts[:path].delete(:layout)
    link_to_view(:overlay_rule, (setting_title + short_help_text), opts)
  end

  def setting_title
    card.name.tag.tr "*", ""
  end

  def short_help_text
    "<div class=\"help-text\">#{card.short_help_text}</div>"
  end

  def rule_content_container
    wrap_with :div, class: "rule-content-container" do
      wrap_with(:span, class: "closed-content content") { yield }
    end
  end

  def link_to_open_rule
    setting_title = card.name.tag.tr "*", ""
    link_to_view :open_rule, setting_title, class: "edit-rule-link slotter"
  end

  def closed_rule_content rule_card
    return "" unless rule_card

    nest rule_card, { view: :closed_content }, set_context: card.name.trunk_name
  end

  def open_rule_setting_links
    wrap_with :div, class: "rule-setting" do
      [link_to_closed_rule, link_to_all_rules]
    end
  end

  def link_to_all_rules
    link_to_card card.rule_setting_name, "all #{card.rule_setting_title} rules",
                 class: "setting-link", target: "wagn_setting"
  end

  def link_to_closed_rule
    link_to_view :closed_rule, card.rule_setting_title,
                 class: "close-rule-link slotter"
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

  view :edit_rule, cache: :never, tags: :unknown_ok do
    edit_rule_form do
      [hidden_tags(success: @edit_rule_success),
       rule_editor,
       edit_rule_buttons].join
    end
  end

  def rule_set_description
    card.rule_set.short_label
  end

  def rule_editor
    wrap_with(:div, class: "card-editor") do
      [rules_type_formgroup,
       rule_content_formgroup,
       rule_set_selection].compact
    end
  end

  def rules_type_formgroup
    return unless card.right.rule_type_editable

    success = @edit_rule_success
    wrap_type_formgroup do
      type_field(
        href: path(mark: success[:id], view: success[:view], type_reload: true),
        class: "type-field rule-type-field live-type-field",
        "data-remote" => true
      )
    end
  end

  def rule_content_formgroup
    formgroup "content", editor: "content", help: false do
      content_field true
    end
  end

  def current_set_key
    card.new_card? ? Card.quick_fetch(:all).name.key : card.rule_set_key
  end

  view :edit_single_rule, tags: :unknown_ok, cache: :never do
    frame { render_edit_rule }
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
