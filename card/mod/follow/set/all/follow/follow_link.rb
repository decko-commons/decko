format do
  def show_follow?
    Auth.signed_in? && !card.new_card? && card.followable?
  end

  def follow_link_hash
    toggle = card.followed? ? :off : :on
    hash = { class: "follow-toggle-#{toggle}" }
    hash.merge! send("follow_link_#{toggle}_hash")
    hash[:path] = path mark: follow_link_mark,
                       action: :update,
                       success: { layout: :modal, view: :follow_status },
                       card: { content: "[[#{hash[:content]}]]" }
    hash
  end

  def follow_link_on_hash
    { content: "*always",
      title: follow_link_title("send"),
      verb: "follow" }
  end

  def follow_link_off_hash
    { content: "*never",
      title: follow_link_title("stop sending"),
      verb: "unfollow" }
  end

  def follow_link_title action
    "#{action} emails about changes to #{card.follow_label}"
  end

  def follow_link_mark
    card.follow_set_card.follow_rule_name Auth.current.name
  end
end

format :json do
  view :follow_status do
    follow_link_hash
  end
end

format :html do
  view :follow_link do
    follow_link
  end

  def follow_link opts={}, icon=false
    hash = follow_link_hash
    link_opts = opts.merge(
      path: hash[:path],
      title: hash[:title],
      "data-path": hash[:path],
      "data-toggle": "modal",
      "data-target": "#modal-#{card.name.safe_key}",
      class: css_classes("follow-link", opts[:class])
    )
    link_to follow_link_text(icon, hash[:verb]), link_opts
  end

  def follow_link_text icon, verb
    verb = %(<span class="follow-verb menu-item-label">#{verb}<span>)
    icon = icon ? icon_tag(:flag) : ""
    [icon, verb].compact.join.html_safe
  end
end
