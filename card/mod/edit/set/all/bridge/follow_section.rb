format :html do
  def follow_section
    return unless show_follow?
    wrap_with :div, class: "mb-3" do
      [follow_button, followers_bridge_link]
    end
  end

  def follow_button
    wrap_with :div, class: "btn-group btn-group-sm" do
      [follow_bridge_link, follow_advanced]
    end
  end

  def follow_advanced
    link_to_card([card, :follow], icon_tag("more_horiz"), class:"btn btn-sm btn-primary")]
  end

  def follow_bridge_link
    opts = { class: "btn btn-sm btn-primary" }
    hash = follow_link_hash
    link_opts = opts.merge(
      path: hash[:path],
      title: hash[:title],
      "data-path": hash[:path],
      "data-hover-text": "follow",
      #"data-slot-selector": bridge_slot_selector,
      remote: true,
      class: css_classes("follow-link", opts[:class], "slotter")
    )
    link_to follow_link_text(false, hash[:verb]), link_opts
  end

  def followers_bridge_link
    cnt = card.followers_count
    link_to_card card.name.field(:followers), "#{cnt} follower#{'s' unless cnt == 1}",
                 bridge_link_opts(class: "btn btn-sm ml-2 btn-secondary", remote: true)
  end
end