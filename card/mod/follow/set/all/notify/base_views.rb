format do
  view :list_of_changes, denial: :blank, cache: :never do
    action = notification_action voo.action_id
    relevant_fields(action).map do |type|
      edit_info_for(type, action)
    end.compact.join
  end

  view :subedits, perms: :none, cache: :never do
    return unless notification_act

    wrap_subedits do
      notification_act.actions_affecting(card).map do |action|
        next if action.card_id == card.id

        action.card.format(format: @format).render_subedit_notice action_id: action.id
      end
    end
  end

  view :subedit_notice, cache: :never do
    action = notification_action voo.action_id
    wrap_subedit_item do
      %(#{name_before_action action} #{action.action_type}d\n) +
        render_list_of_changes(action_id: action.id)
    end
  end

  view :followed, perms: :none, closed: true do
    if (set_card = followed_set_card) && (option_card = follow_option_card)
      option_card.description set_card
    else
      "*followed set of cards*"
    end
  end

  view :follower, perms: :none, closed: true do
    active_notice(:follower) || "follower"
  end

  view :last_action_verb, cache: :never do
    return unless notification_act

    "#{notification_act.main_action.action_type}d"
  end

  view :unfollow_url, perms: :none, closed: true, cache: :never do
    return "" unless (rule_name = live_follow_rule_name)

    card_url path(mark: "#{active_notice(:follower)}+#{Card[:follow].name}",
                  action: :update,
                  card: { subcards: { rule_name => Card[:never].name } })
  end

  def relevant_fields action
    case action.action_type
    when :create then %i[cardtype content]
    when :update then %i[name cardtype content]
    when :delete then %i[content]
    end
  end

  def name_before_action action
    (action.value(:name) && action.previous_value(:name)) || card.name
  end

  def followed_set_card
    (set_name = active_notice(:followed_set)) && Card.fetch(set_name)
  end

  def follow_option_card
    return unless (option_name = active_notice(:follow_option))

    Card.fetch option_name
  end

  def active_notice key
    @active_notice ||= inherit :active_notice
    return unless @active_notice

    @active_notice[key]
  end

  def live_follow_rule_name
    return unless (set_card = followed_set_card) && (follower = active_notice(:follower))

    set_card.follow_rule_name follower
  end

  def edit_info_for field, action
    return nil unless (value = action.value field)
    value = action.previous_value if action.action_type == :delete
    wrap_list_item "  #{notification_action_label action} #{field}: #{value}"
  end

  def notification_action_label action
    case action.action_type
    when :update then "new"
    when :delete then "deleted"
    end
  end

  def wrap_subedits
    subedits = yield.compact.join
    return "" if subedits.blank?

    "\nThis update included the following changes:\n#{wrap_list subedits}"
  end

  def wrap_list list
    "\n#{list}\n"
  end

  def wrap_list_item item
    "#{item}\n"
  end

  def wrap_subedit_item
    "\n#{yield}\n"
  end

  def notification_act act=nil
    @notification_act ||= act || card.acts.last
  end

  def notification_action action_id
    action_id ? Action.fetch(action_id) : card.last_action
  end
end
