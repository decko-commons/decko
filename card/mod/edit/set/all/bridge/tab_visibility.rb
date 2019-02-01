format :html do
  def visible_bridge_tabs
    BRIDGE_TABS.select do |key, _title|
      send "show_#{key}?"
    end
  end

  private

  def show_account_tab?
    return unless card.real?

    card.account && card.ok?(:update)
  end

  def show_engage_tab?
    return unless card.real?

    show_follow? || show_discussion?
  end

  def show_history_tab?
    card.real?
  end

  def show_related_tab?
    card.real?
  end

  def show_rules_tab?
    true
  end

  def show_discussion?
    d_card = discussion_card
    return unless d_card

    permission_task = d_card.new_card? ? :comment : :read
    d_card.ok? permission_task
  end

  def discussion_card?
    card.junction? && card.name.tag_name.key == :discussion.cardname.key
  end

  def discussion_card
    return if card.new_card? || discussion_card?

    card.fetch trait: :discussion, skip_modules: true, new: {}
  end
end
