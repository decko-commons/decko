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
      wrap_with(:h5, setting_title, class: "title font-weight-bold")
      # render_overlay_rule_help
    ]
  end

  def current_rule
    if params[:assign]
      card
    elsif (existing = find_existing_rule_card)
      existing
    else
      card
    end
  end

  def quick_editor
    rule_content_formgroup
  end

  def setting_title
    card.name.tag.tr "*", ""
  end

  def short_help_text
    "<div class=\"help-text\">#{card.short_help_text}</div>"
  end

  def rule_set_description
    card.rule_set.follow_label
  end

  def rules_type_formgroup
    return unless card.right.rule_type_editable

    success = @edit_rule_success
    wrap_type_formgroup do
      type_field(
        href: path(mark: success[:id], view: :rule_form, assign: true),
        class: "type-field rule-type-field live-type-field",
        "data-remote" => true
      )
    end
  end

  def rule_content_formgroup
    _render_content_formgroup hide: :conflict_tracker
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
