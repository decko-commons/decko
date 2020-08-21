format :html do
  def follow_section
    return unless show_follow?

    wrap_with :div, class: "mb-3" do
      [follow_button_group, followers_bridge_link, follow_overview_button]
    end
  end

  def follow_button_group
    wrap_with :div, class: "btn-group btn-group-sm follow-btn-group" do
      [follow_button, follow_advanced]
    end
  end

  def follow_overview_button
    link_to_card [Auth.current, :follow], "all followed cards",
                 bridge_link_opts(class: "btn btn-sm btn-secondary",
                                  "data-cy": "follow-overview")
  end

  def follow_advanced
    opts = bridge_link_opts(class: "btn btn-sm btn-primary",
                            path: { view: :overlay_rule },
                            "data-cy": "follow-advanced")
    opts[:path].delete :layout
    link_to_card card.follow_rule_card(Auth.current.name, new: {}),
                 icon_tag("more_horiz"), opts
  end

  def followers_bridge_link
    cnt = card.followers_count
    link_to_card card.name.field(:followers), "#{cnt} follower#{'s' unless cnt == 1}",
                 bridge_link_opts(class: "btn btn-sm ml-2 btn-secondary slotter",
                                  remote: true, "data-cy": "followers")
  end
end
