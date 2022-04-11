# DEPRECATED
#
# The card "*follow defaults"
#
# Despite its name, this card does not influence defaults for *follow rules.
# What it does is provide a mechanism (with interface) for updating all users so that
# they follow the items that are its content.
#
# PLAN:
# - actual defaults should be handled as much as possible with something like
#   the *defaults rule
# - on the *admin page, we can have a link so sharks can update all the pristine cards
#   to use whatever the actual defaults representation is (see previous point)
# - if you truly want to override existing follow rules, that may be monkey territory?
# - we will delete "*follow defaults" after the above are completed

event :update_follow_rules, :finalize, on: :save, trigger: :required do
  Auth.as_bot do
    Card.search(type: "user").each do |user|
      follow_defaults.each do |set_card, option|
        follow_rule = Card.fetch(set_card.follow_rule_name(user.name), new: {})
        next unless follow_rule

        follow_rule.drop_item "*never"
        follow_rule.drop_item "*always"
        follow_rule.add_item option
        follow_rule.save!
      end
    end
  end
  Card.follow_caches_expired
end

def follow_defaults
  item_names.map do |item|
    if (set_card = Card.fetch item.to_name.left)&.type_code == :set
      [set_card, follow_option(item)]
    end
  end.compact
end

def follow_option item
  option_card =
    Card.fetch(item.to_name.right) || Card[item.to_name.right.to_sym]
  option_card.follow_option? ? option_card.name : "*always"
end

format :html do
  view :edit_buttons do
    render_confirm_update_all +
    button_formgroup do
      [submit_and_update_button, simple_submit_button, cancel_to_edit_button]
    end
  end

  def submit_and_update_button
    submit_button text: "Submit and update all users",
                  name: "card[trigger]", value: "update_follow_rules",
                  disable_with: "Updating", class: "follow-updater"
  end

  def simple_submit_button
    button_tag "Submit", class: "follow"
  end

  def cancel_to_edit_button
    cancel_button href: path(view: :edit, id: card.id)
  end

  view :confirm_update_all do
    wrap do
      alert "info" do
        %(
          <h1>Are you sure you want to change the default follow rules?</h1>
          <p>You may choose to update all existing users.
             This may take a while. </p>
        )
      end
    end
  end
end
