format :html do
  view :type do
    link_to_card card.type_card, nil, class: "cardtype"
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
    act = card.last_act
    return unless act

    action = act.action_on card.id
    return unless action

    action_verb =
      case action.action_type
      when :create then "added"
      when :delete then "deleted"
      else
        link_to_view :history, "edited", class: "last-edited", rel: "nofollow"
      end

    %(
      <span class="last-update">
        #{action_verb} #{_render_acted_at} ago by
        #{subformat(card.last_actor)._render_link}
      </span>
    )
  end

  view :type_info do
    return unless show_view?(:toolbar, :hide) && card.type_code != :basic

    wrap_with :span, class: "type-info float-right" do
      link_to_card card.type_name, nil, class: "navbar-link"
    end
  end

  view :overview do
    %i[bar box infobar open closed titled labeled content content_panel].map do |v|
      wrap_with :p, [content_tag(:h3, v), render(v, show: :menu)]
    end.flatten.join ""
  end

  view :viewer do
    %i[bar box infobar open closed labeled titled content content_panel].map do |v|
      wrap_with :p, [content_tag(:h3, v), render(v, show: :menu)]
    end.flatten.join ""
  end

end
