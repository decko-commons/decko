# History views

format :html do
  view :history, cache: :never do
    frame do
      class_up "d0-card-body",  "history-slot"
      acts_layout card.history_acts, :relative, :show
    end
  end

  view :act, cache: :never do
    act_listing act_from_context
  end

  view :act_legend do
    bs_layout do
      row md: [12, 12], lg: [7, 5], class: "pb-3" do
        col action_legend
        col content_legend, class: "text-end"
      end
    end
  end

  view :draft_legend do
    "#{action_icon(:draft)} unsaved draft"
  end

  view :action_summary do
    action_content action_from_context, :summary
  end

  view :action_expanded do
    action_content action_from_context, :expanded
  end

  view :change do
    voo.show :title_link
    voo.hide :menu
    wrap do
      [_render_title,
       _render_menu,
       _render_last_action]
    end
  end

  view :last_action do
    %(
      <span class="last-update">
        #{render_last_action_verb} #{render_acted_at} ago by
        #{nest card.last_actor, view: :link}
      </span>
    )
  end

  view :last_action_verb, cache: :never do
    return unless (act = card.last_act)
    return unless (action = act.action_on card.id)

    case action.action_type
    when :create then "added"
    when :delete then "deleted"
    else
      link_to_view :history, "edited", class: "last-edited", rel: "nofollow"
    end
  end
end
