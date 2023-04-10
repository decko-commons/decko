format :html do
  def visible_board_tabs
    Board::BOARD_TABS.select do |_title, view|
      send "show_#{view}?"
    end
  end

  private

  def show_engage_tab?
    return unless card.real?

    show_follow? || show_discussion?
  end

  def show_account_tab?
    false
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

  def show_guide_tab?
    guide.present?
  end

  def show_discussion?
    return unless (d_card = discussion_card)

    d_card.ok? discussion_permission_task(d_card)
  end

  def discussion_card?
    card.compound? && card.name.tag_name.key == :discussion.cardname.key
  end

  def discussion_card
    return if card.new_card? || discussion_card?

    card.fetch :discussion, skip_modules: true, new: {}
  end

  private

  def discussion_permission_task d_card=nil
    d_card ||= discussion_card
    d_card.new_card? ? :update : :read
  end
end
