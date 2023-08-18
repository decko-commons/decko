#! no set module
class RuleSetRadio
  attr_reader :format

  delegate :link_to_card, :radio_button, :wrap_with, :icon_tag, :unique_id,
           to: :format

  # @param state [:current, :overwritten]
  def initialize format, set_name, tag, state
    @format = format
    @card = format.card
    @set_name = set_name
    @tag = tag
    @state = state
    @id = "#{unique_id}-#{Time.now.to_i}"
  end

  def html narrower
    @narrower_rules = narrower

    wrap_with :div, class: "form-check" do
      [radio, label]
    end
  end

  private

  def current?
    @state == :current
  end

  def overwritten?
    @state == :overwritten
  end

  def radio
    radio_text = "#{@set_name}+#{@tag}"
    radio_button :name, radio_text,
                 checked: false, warning: warning, class: "form-check-input", id: @id
  end

  def label
    label_classes = ["set-label", ("current-set-label" if current?)].compact.join(" ")
    icon = icon_tag :new_window, "text-muted"
    text = Card.fetch(@set_name).label
    text += " <em>#{extra_info}</em>".html_safe if extra_info

    wrap_with :label, class: "form-check-label #{label_classes}", for: @id do
      [text, link_to_card(@set_name, icon, target: "decko_set")]
    end
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
