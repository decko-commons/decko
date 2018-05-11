# The Right::Follow set configures follow preferences (`[Set]+[User]+:follow`)
# While the user follow dashboard ([User]+:follow`) is also in this Set, its
# customizations are handled in TypePlusRight::User::Follow

include All::Permissions::Follow

event :cache_expired_for_new_preference, :integrate, when: :is_preference? do
  Card.follow_caches_expired
end

def option_cards
  Card::FollowOption.cards.compact
end

def options_rule_card
  Card.new(
    name: "follow_options_card",
    type_code: :pointer,
    content: option_cards.map { |oc| "[[#{oc.name}]]" }.join("\n")
  )
end

def add_follow_item? condition
  new_card? || !include_item?(condition)
end

format :html do
  view :follow_status do
    [
        "<h4>Get notified about changes</h4>",
        render!(:follow_status_delete_options),
        follow_status_link
    ].join "\n\n"
  end

  def follow_status_link
    # simplified this to straight link for now.
    # consider restoring to slotter action
    link_to_card card.name, "more options",
                 path: { view: :edit_single_rule },
                 class: "btn update-follow-link",
                 "data-card_key": card.set_prototype.key
  end

  view :follow_status_delete_options, cache: :never do
    wrap_with(:ul, class: "delete-list list-group") do
      card.item_names.map do |option|
        wrap_with :li, class: "list-group-item" do
          condition = option == "*never" ? "*always" : option
          subformat(card).follow_item condition
        end
      end.join "\n"
    end
  end

  view :delete_follow_rule_button do
    button_tag(type: :submit,
               class: "btn-xs btn-item-delete btn-primary",
               "aria-label" => "Left Align") do
      tag :span, class: "glyphicon glyphicon-ok", "aria-hidden" => "true"
    end
  end

  view :add_follow_rule_button do
    button_tag(type: :submit,
               class: "btn-xs btn-item-add",
               "aria-label" => "Left Align") do
      tag :span, class: "glyphicon glyphicon-plus", "aria-hidden" => "true"
    end
  end

  view :follow_item do
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

  def follow_item_hidden_tags condition
    condkey = card.add_follow_item?(condition) ? :add_item : :drop_item
    hidden_tags condition: condition, condkey => condition
  end

  def follow_item_button condition
    action = card.add_follow_item?(condition) ? :add : :delete
    _render "#{action}_follow_rule_button"
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
