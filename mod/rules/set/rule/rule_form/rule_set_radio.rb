#! no set module
class RuleSetRadio
  attr_reader :format

  delegate :link_to_card, :radio_button, :wrap_with, :icon_tag,
           to: :format

  # @param state [:current, :overwritten]
  def initialize format, set_name, tag, state
    @format = format
    @card = format.card
    @set_name = set_name
    @tag = tag
    @state = state
  end

  def html narrower
    @narrower_rules = narrower

    rule_radio do
      radio_text = "#{@set_name}+#{@tag}"
      radio_button :name, radio_text, checked: false, warning: warning
    end
  end

  private

  def current?
    @state == :current
  end

  def overwritten?
    @state == :overwritten
  end

  def rule_radio
    label_classes = ["set-label", ("current-set-label" if current?)]
    icon = icon_tag "open_in_new", "text-muted"
    wrap_with :label, class: label_classes.compact.join(" ") do
      [yield, label, link_to_card(@set_name, icon, target: "decko_set")]
    end
  end

  def label
    label = Card.fetch(@set_name).label
    label += " <em>#{extra_info}</em>".html_safe if extra_info
    label
  end

  def extra_info
    case @state
    when :current
      "(current)"
    when :overwritten, :exists
      link_to_card "#{@set_name}+#{@card.rule_user_setting_name}", "(#{@state})",
                   target: "_blank"
    end
  end

  def warning
    if @set_name == "*all"
      "This rule will affect all cards! Are you sure?"
    else
      narrower_warning
    end
  end

  # warn user if rule change won't have a effect on the current card
  # because there is a narrower rule
  def narrower_warning
    return unless @state.in? %i[current overwritten]

    @narrower_rules << Card.fetch(@set_name).uncapitalized_label
    return unless @state == :overwritten

    narrower_warning_message
  end

  def narrower_warning_message
    plural = @narrower_rules.size > 1 ? "s" : ""
    "This rule will not have any effect on this card unless you delete " \
    "the narrower rule#{plural} for #{@narrower_rules.to_sentence}."
  end
end
