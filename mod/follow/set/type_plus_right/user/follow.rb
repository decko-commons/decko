FOLLOW_TABS = { "Follow" => { view: "follow_tab" },
                "Ignore" => { view: "ignore_tab" } }.freeze

# a virtual pointer to the sets that a user is following.
# (data is stored in preferences: `[Set]+[User]+:follow`)

include_set Abstract::List
def virtual?
  new?
end

# overrides pointer default
def item_names _args={}
  if (user = left)
    Card::Rule.preference_names user.name, "follow"
  else
    []
  end
end

def suggestions
  Card[:follow_suggestions]&.item_names || []
end

def current_user?
  Auth.signed_in? && Auth.current_id == left.id
end

format :html do
  view :one_line_content do
    ""
  end

  view :edit do
    render :open
  end

  # renders follow tab and ignore tab
  view :core do
    tabs FOLLOW_TABS, "Follow", load: :lazy do
      render_follow_tab
    end
  end

  view :follow_tab, cache: :never do
    haml :follow_editor, items_method: :following_rules_and_options
  end

  view :ignore_tab, cache: :never do
    haml :follow_editor, items_method: :ignoring_rules_and_options
  end

  def show_button?
    card.current_user? || Auth.always_ok?
  end

  def pointer_items args
    voo.items[:view] ||= :link
    super
  end

  # TODO: research and generalize
  # LOCALIZE
  # this does not look specific to following!
  view :errors, perms: :none do
    return unless card.errors.any?

    if card.errors.find { |attrib, _msg| attrib == :permission_denied }
      Env.save_interrupted_action(request.env["REQUEST_URI"])
      voo.title = "Problems with #{card.name}"
      class_up "d0-card-frame", "card card-warning card-inverse"
      frame do
        "Please #{link_to_card :signin, 'sign in'}" # " #{to_task}"
      end
    else
      super()
    end
  end
end
