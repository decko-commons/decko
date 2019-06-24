def virtual?
  new?
end

format :html do
  view :core do
    if card.left && Auth.signed_in?
      render_rule_editor
    else
      nest Card.fetch(card.name.left, :followers), view: :titled, items: { view: :link }
    end
  end

  view :status do
    if (rcard = current_follow_rule_card)
      rcard.item_cards.map do |item|
        %(<div class="alert alert-success" role="alert">
          <strong>#{rcard.rule_set.follow_label}</strong>: #{item.title}
         </div>)
      end.join
    else
      "No following preference"
    end
  end

  view :closed_content do
    ""
  end

  view :rule_editor, cache: :never do
    rule_context = Card.fetch preference_name, new: { type_id: PointerID }
    wrap_with :div, class: "edit-rule" do
      follow_context = current_follow_rule_card || rule_context
      subformat(follow_context).rule_form :open, rule_context, :modal
    end
  end

  def preference_name
    set_name = card.left.follow_set_card.name
    Card::Name[set_name, Auth.current.name, :follow]
  end

  def edit_rule_success
    { view: "status", id: card.name.url_key }
  end

  def current_follow_rule_card
    card.left.rule_card :follow, user: Auth.current
  end
end
