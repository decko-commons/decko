format :html do

  view :open_rule, cache: :never, tags: :unknown_ok do
    return "not a rule" unless card.is_rule?

    # rule_view = open_rule_body_view
    # open_rule_wrap(rule_view) do
    #   [render_rule_help,
    #    open_rule_setting_links,
    #    open_rule_body(rule_view)]
    # end

    #@edit_rule_success = edit_rule_success :closed_rule

    open_rule_wrap :show_rule do
      current_rule_form success_view: :closed_rule
    end
  end

  view :closed_rule, cache: :never, tags: :unknown_ok do
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

  def open_rule_wrap rule_view
    rule_view_class = rule_view.to_s.tr "_", "-"
    wrap_with :tr, class: "card-slot open-rule #{rule_view_class}" do
      wrap_with(:td, class: "rule-cell", colspan: 3) { yield }
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
