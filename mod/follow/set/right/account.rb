def send_change_notice act, followed_set, follow_option
  return unless email.present? && changes_visible?(act)

  notify_of_act act do
    { follower: left.name, followed_set: followed_set, follow_option: follow_option }
  end
end

def notify_of_act act
  Auth.as(left.id) do
    Card[:follower_notification_email].deliver(
      act.card, { to: email }, { auth: left, active_notice: yield }
    )
  end
end
