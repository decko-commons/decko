attr_accessor :follower_stash
mattr_accessor :force_notifications

event :silence_notifications, :initialize, when: :silence_notifications? do
  @silent_change = true
end

def silence_notifications?
  !(Card::Env[:controller] || force_notifications)
end

event :notify_followers_after_save,
      :integrate_with_delay, on: :save, when: :notable_change? do
  notify_followers
end

# in the delete case we have to calculate the follower_stash beforehand
# but we can't pass the follower_stash through the ActiveJob queue.
# We have to deal with the notifications in the integrate phase instead of the
# integrate_with_delay phase
event :stash_followers, :store, on: :delete, when: :notable_change? do
  act_card.follower_stash ||= FollowerStash.new
  act_card.follower_stash.check_card self
end

event :notify_followers_after_delete, :integrate, on: :delete, when: :notable_change? do
  notify_followers
end

def notify_followers
  return unless (act = Card::Director.act)

  act.reload
  notify_followers_of act
end

def notable_change?
  !silent_change? && current_act_card? &&
    (Card::Auth.current_id != WagnBotID) && followable?
end

def silent_change?
  silent_change
end

private

def notify_followers_of act
  act_followers(act).each_follower_with_reason do |follower, reason|
    next if !follower.account || (follower == act.actor)

    notify_follower follower, act, reason
  end
end

def notify_follower follower, act, reason
  follower.account.send_change_notice act, reason[:set_card].name, reason[:option]
end

def act_followers act
  @follower_stash ||= FollowerStash.new
  act.actions(false).each do |a|
    next if !a.card || a.card.silent_change?

    @follower_stash.check_card a.card
  end
  @follower_stash
end

def silent_change
  @silent_change || @supercard&.silent_change
end

def current_act_card?
  return false unless act_card

  act_card.id.nil? || act_card.id == id
  # FIXME: currently card_id is nil for deleted acts (at least
  # in the store phase when it's tested).  The nil test was needed
  # to make this work.
end
