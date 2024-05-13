# The Right::Follow set configures follow preferences (`[Set]+[User]+:follow`)
# While the user follow dashboard ([User]+:follow`) is also in this Set, its
# customizations are handled in TypePlusRight::User::Follow

assign_type :list

event :cache_expired_for_new_preference, :integrate, when: :preference? do
  Card.follow_caches_expired
end

def option_cards
  Card::FollowOption.cards.compact
end

def options_card
  Card.new(
    name: "follow_options_card",
    type: :list,
    content: option_cards.map { |oc| "[[#{oc.name}]]" }.join("\n")
  )
end

def add_follow_item? condition
  new_card? || !include_item?(condition)
end

def ok_to_update?
  permit :update
end

def ok_to_create?
  permit :create
end

def ok_to_delete?
  permit :delete
end

def raw_help_text
  "Get notified about changes"
end

def permit action, verb=nil
  if %i[create delete update].include?(action) && allowed_to_change_follow_status?
    true
  else
    super action, verb
  end
end

def allowed_to_change_follow_status?
  Auth.signed_in? &&
    ((user = rule_user) && Auth.current_id == user.id) || Auth.always_ok?
end

format :html do
  # shows a follow item link for each of the current follow options
  view :follow_status, cache: :never do
    wrap { haml :follow_status }
  end

  # interface to view/alter a specific rule option
  view :follow_item, cache: :never do
    follow_item Env.params[:condition]
  end

  def follow_item condition, button=true
    condition ||= "*always"
    wrap do
      card_form action: :update, success: { view: :follow_item } do
        [
          follow_item_hidden_tags(condition),
          (follow_item_button(condition) if button),
          follow_item_link(condition)
        ].compact
      end
    end
  end

  def rule_form_args
    super.merge "data-update-foreign-slot": ".card-slot.follow_section-view"
  end

  private

  def follow_item_hidden_tags condition
    condkey = card.add_follow_item?(condition) ? :add_item : :drop_item
    hidden_tags condition: condition, condkey => condition
  end

  def follow_item_button condition
    action = card.add_follow_item?(condition) ? :add : :delete
    button_tag type: :submit, "aria-label": "Left Align",
               class: "btn-sm btn-item #{follow_item_button_class action}" do
      follow_item_icon action
    end
  end

  def follow_item_button_class action
    action == :add ? "btn-item-add" : "btn-item-delete btn-primary"
  end

  def follow_item_icon action
    icon_tag(action == :add ? :add : :check)
  end

  def follow_item_link condition
    link_to_card follow_item_link_target, follow_item_link_text(condition)
  end

  def follow_item_link_target
    set = card.rule_set
    setname = set.name
    set.tag.codename == :self ? setname.left : setname.field("by name")
  end

  def follow_item_link_text condition
    if (option_card = Card.fetch condition)
      option_card.description card.rule_set
    else
      card.rule_set.follow_label
    end
  end
end
