
def virtual?
  !real?
end

format :html do
  view :core do
    if card.left && Auth.signed_in?
      render_rule_editor
    else
      fname = "#{card.name.left}+#{Card[:followers].name}"
      fcard = Card.fetch fname
      nest fcard, view: :titled, items: { view: :link }
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

  view :rule_editor do
    preference_name = [
      card.left.default_follow_set_card.name,
      Auth.current.name,
      Card[:follow].name
    ].join Card::Name.joint
    rule_context = Card.fetch preference_name, new: { type_id: PointerID }

    wrap_with :div, class: "edit-rule" do
      follow_context = current_follow_rule_card || rule_context
      edit_rule_format = subformat follow_context.render_edit_rule
      edit_rule_format.rule_context = rule_context
      edit_rule_format.render :edit_rule
    end
  end

  def edit_rule_success
    { view: "status", id: card.name.url_key }
  end

  def current_follow_rule_card
    card.left.rule_card :follow, user: Auth.current
  end
end
