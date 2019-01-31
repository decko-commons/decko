format :html do
  view :open_rule, cache: :never, tags: :unknown_ok,
                   wrap: { modal: { size: :large,
                                    title: :edit_rule_title,
                                    footer: "" } } do
    return "not a rule" unless card.is_rule?

    current_rule_form success_view: :rule_row, form_type: :modal
  end

  def edit_rule_title
    output [
      wrap_with(:h5, setting_title, class: "title font-weight-bold"),
      render_overlay_rule_help
    ]
  end

  view :rule_row, cache: :never, tags: :unknown_ok do
    return "not a rule" unless card.is_rule?

    rule_card = find_existing_rule_card
    cols = %i[setting set]
    cols.insert(1, :content) if voo.show? :content
    wrap_closed_rule rule_card do
      cols.map do |cell|
        send "closed_rule_#{cell}_cell", rule_card
      end
    end
  end

  # def open_rule_body rule_view
  #   wrap_with :div, class: "d0-card-body" do
  #     current_rule_format = subformat current_rule
  #     current_rule_format.rule_context = card
  #     current_rule_format.render rule_view
  #   end
  # end
  #
  #   def open_rule_body_view
  #     return :show_rule if params[:success] && !params[:type_reload]
  #
  #     card_action = card.new_card? ? :create : :update
  #     card.ok?(card_action) ? :edit_rule : :show_rule
  #   end
end
